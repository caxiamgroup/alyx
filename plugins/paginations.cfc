<cfcomponent name="paginations">

	<cffunction name="init">
		<cfargument name="pageRange" default = "#APPLICATION.controller.getSetting("PAGINATION_DEFAULT_PAGE_RANGE", 10)#" />
		<cfargument name="rendering" default = "#APPLICATION.controller.getSetting("PAGINATION_DEFAULT_RENDERING", 'default')#" />
		<cfset mapRenderings(getMetaData(this)) />

		<cfset VARIABLES.validOrderBY = ['asc','desc'] />
		<cfset VARIABLES.filters = "pageSize,pageIndex" />
		<cfset VARIABLES.pageRange = arguments.pageRange />
		<cfset VARIABLES.pageIndex = 1 />
		<cfset VARIABLES.rendering = arguments.rendering />
		<cfreturn this />
	</cffunction>

	<cffunction name="mapRenderings">
		<cfargument name="metadata" required="yes" />

		<cfset getPluginFromPath(path = arguments.metadata.path) />

		<cfif StructKeyExists(arguments.metadata, "extends")>
			<cfset mapRenderings(arguments.metadata.extends)>
		</cfif>
	</cffunction>

	<cffunction name="getPluginFromPath">
		<cfargument name="path" />
		<cfset local.path = GetDirectoryfrompath(arguments.path) & "paginations/renderings" />
		<cfset local.pattern = "(\w+\:\\)*(\w+[\\\/])+(alyx\/\\)*(\w+[\\\/]plugins[\\\/])(\w+[\\\/])+(renderings[\\\/])(\w+)(\.\w+)$" />

		<cfif !DirectoryExists(local.path)>
			<cfreturn false />
		</cfif>

		<cfloop array="#DirectoryList(local.path, true)#" index="local.renderingPath">
			<cfset local.renderingObjectPath = ListChangeDelims(REReplaceNocase(local.renderingPath, local.pattern, "\4\5\6\7", "ALL"), ".", "\/") />
			<cfset local.renderingName = ListLast(local.renderingObjectPath, ".") />

			<cftry>
				<cfset local.rendering = CreateObject("component", local.renderingObjectPath) />
				<cfset VARIABLES.renderings[local.renderingName] = local.renderingObjectPath />
				<cfdump var="#local.rendering#">
			<cfcatch>
				<cfthrow
					message = "There was a problem while trying to pull renderings from your local rendering folder. The rendering path was #local.renderingPath#."
				/>
			</cfcatch>
			</cftry>
		</cfloop>

	</cffunction>

	<cffunction name="getPaginatedResult" access="public">
		<cfargument name="serviceName" />/
		<cfargument name="serviceArguments" default="#StructNew()#" />
		<cfargument name="rc" default="#REQUEST.context#"/>
		<cfargument name="filters" default="" />
		<cfargument name="form">
		<cfargument name="methodName" />
		<cfargument name="rendering" default="#VARIABLES.rendering#" />


		<cfset ARGUMENTS.rc = Duplicate(ARGUMENTS.rc) />

		<cfif StructKeyExists(ARGUMENTS, "form")>
			<cfset setFiltersAndLocalRequestFromForm(pagedArguments = ARGUMENTS) />
		</cfif>

		<cfset ARGUMENTS.filters = ListAppend(ARGUMENTS.filters, VARIABLES.filters) />

		<cfset setValidFiltersFromRequest(
			rc = ARGUMENTS.rc,
			serviceArguments = ARGUMENTS.serviceArguments,
			filters = ARGUMENTS.filters)
		/>

		<cfset local.result.result = getServiceResult(
			serviceName = ARGUMENTS.serviceName,
			methodName = ARGUMENTS.methodName,
			serviceArguments = ARGUMENTS.serviceArguments
		) />

		<cfif ArrayLen(local.result.result) EQ 0 && local.result.result.getRecordCount() GT 0>
			<cfset ARGUMENTS.serviceArguments.pageIndex = local.result.result.getPageCount() />
			<cfset local.result.result = getServiceResult(
				serviceName = ARGUMENTS.serviceName,
				methodName = ARGUMENTS.methodName,
				serviceArguments = ARGUMENTS.serviceArguments
			) />
		</cfif>

		<cfset local.result.pagination = getPagination(
				rc = ARGUMENTS.rc,
				serviceArguments = ARGUMENTS.serviceArguments,
				isFilterApplied = ARGUMENTS.serviceArguments.isFilterApplied,
				pageSize = local.result.result.getPageSize(),
				pageCount = local.result.result.getPageCount(),
				recordCount = local.result.result.getRecordCount(),
				pageIndex = local.result.result.getPageIndex(),
				startIndex = local.result.result.getStartIndex(),
				endIndex = local.result.result.getEndIndex(),
				rendering = ARGUMENTS.rendering
			)/>

		<cfreturn local.result />
	</cffunction>

	<cffunction name="setFiltersAndLocalRequestFromForm">
		<cfargument name="pagedArguments" required="yes">
		<cfset local.fieldNames  = ListToArray(ARGUMENTS.pagedArguments.form.getFieldNames()) />
		<cfloop array="#local.fieldNames#" index="local.fieldName">
			<cfset ARGUMENTS.pagedArguments.rc[local.fieldName] = ARGUMENTS.pagedArguments.form.getFieldValue(local.fieldName)/>
			<cfset ARGUMENTS.pagedArguments.filters = ListAppend(ARGUMENTS.pagedArguments.filters, local.fieldName) />
		</cfloop>
	</cffunction>

	<cffunction name="getServiceResult">
		<cfargument name="serviceName" />
		<cfargument name="methodName" />
		<cfargument name="serviceArguments" />
		<cfset local.service = APPLICATION.controller.getService(ARGUMENTS.serviceName) />
		<cfinvoke
			component="#local.service#"
			method="#ARGUMENTS.methodName#"
			argumentcollection="#ARGUMENTS.serviceArguments#"
			returnvariable="local.result"
			/>
		<cftry>
		<cfreturn local.result />
		<cfcatch>
			<cfthrow type="PAGINATION.SERVICE_UNDEFINED" message="There was an error with the Service.  #UCase(arguments.serviceName)# was probably an invalid Service name or the #UCase(arguments.methodName)# Method you are attempting to call on it was wrong." />
		</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setValidFiltersFromRequest" access="private">
		<cfargument name="rc" />
		<cfargument name="serviceArguments" />
		<cfargument name="filters" />
		<cfset setValidServiceArguments(rc = ARGUMENTS.rc, filters = ARGUMENTS.filters, serviceArguments = ARGUMENTS.serviceArguments )>
		<cfset setValidOrderBy(rc = ARGUMENTS.rc, filters = ARGUMENTS.filters, serviceArguments = ARGUMENTS.serviceArguments) />
	</cffunction>

	<cffunction name="getPagination" access="private">
		<cftry>
			<cfset ARGUMENTS.rendering = CreateObject("component", VARIABLES.renderings[ARGUMENTS.rendering]).init(ArgumentCollection = ARGUMENTS) />
		<cfcatch>
			<cfthrow message="The Rendering #ARGUMENTS.rendering# doesn't exists under renderings. #cfcatch.message#">
		</cfcatch>
		</cftry>

		<cfreturn CreateObject("paginations.pagination").init(ArgumentCollection = ARGUMENTS) />
	</cffunction>

	<cffunction name="setValidOrderBy" output="false" access="private">
		<cfargument name="rc" />
		<cfargument name="filters" type="string" default="" />
		<cfargument name="serviceArguments" />

		<cfif NOT StructKeyExists(ARGUMENTS.serviceArguments, "orderBy") AND (NOT StructKeyExists(ARGUMENTS.rc, "orderBy") OR NOT isValidFilter(ARGUMENTS.filters, ListFirst(ARGUMENTS.rc.orderBy)) )>
			<cfset ARGUMENTS.serviceArguments.orderBy = [] />
		<cfelse>

			<cfif StructKeyExists(ARGUMENTS.serviceArguments, "orderBy")>
				<cfset ARGUMENTS.serviceArguments.orderBy = ListToArray(ARGUMENTS.serviceArguments.orderBy, ", ")>
			</cfif>

			<cfif StructKeyExists(ARGUMENTS.rc, "orderBy") AND isValidFilter(ARGUMENTS.filters, ListFirst(ARGUMENTS.rc.orderBy))>
				<cfset ARGUMENTS.serviceArguments.orderBy = ListToArray(ARGUMENTS.rc.orderBy, ", ")>
			</cfif>

			<cfif ArrayLen(ARGUMENTS.serviceArguments.orderBy) EQ 1 OR NOT ArrayFind(VARIABLES.validOrderBY, ARGUMENTS.serviceArguments.orderBy[2]) >
				<cfset ARGUMENTS.serviceArguments.orderBy[2] = VARIABLES.validOrderBY[1] />
			</cfif>
		</cfif>

		<cfset ARGUMENTS.serviceArguments.orderBy = ArrayToList(ARGUMENTS.serviceArguments.orderBy, " ") />
	</cffunction>

	<cffunction name="isValidFilter" access="private">
		<cfargument name="filters" />
		<cfargument name="filter" />
		<cfreturn ListFind(ARGUMENTS.filters, ARGUMENTS.filter) />
	</cffunction>

	<cffunction name="setValidServiceArguments" access="private">
		<cfargument name="rc" type="struct" />
		<cfargument name="filters" type="string" default="" />
		<cfargument name="serviceArguments" type="struct" />

		<cfset ARGUMENTS.serviceArguments.isFilterApplied = false />
		<cfset local.filters = ListToArray(ARGUMENTS.filters) />

		<cfloop array="#local.filters#" index="local.filter">
			<cfif StructKeyExists(ARGUMENTS.rc, local.filter)>
				<cfif local.filter EQ "pageIndex" OR local.filter EQ "pageSize">
					<cfset ARGUMENTS.serviceArguments[local.filter] = Max(ARGUMENTS.rc[local.filter], 1) />
				<cfelseif LEN(ARGUMENTS.rc[local.filter])>
					<cfset ARGUMENTS.serviceArguments[local.filter] = Trim(ARGUMENTS.rc[local.filter]) />
					<cfif NOT ARGUMENTS.serviceArguments.isFilterApplied>
						<cfset ARGUMENTS.serviceArguments.isFilterApplied = true />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<cfif NOT StructKeyExists(ARGUMENTS.serviceArguments, "pageRange")>
			<cfset ARGUMENTS.serviceArguments["pageRange"] = Max(VARIABLES.pageRange, 1) />
		<cfelse>
			<cfset ARGUMENTS.serviceArguments["pageRange"] = Max(ARGUMENTS.serviceArguments["pageRange"], 1) />
		</cfif>

		<cfif NOT StructKeyExists(ARGUMENTS.serviceArguments, "pageIndex")>
			<cfset ARGUMENTS.serviceArguments["pageIndex"] = Max(VARIABLES.pageIndex, 1) />
		<cfelse>
			<cfset ARGUMENTS.serviceArguments["pageIndex"] = Max(ARGUMENTS.serviceArguments["pageIndex"], 1) />
		</cfif>

		<cfif NOT StructKeyExists(ARGUMENTS.serviceArguments, "pageSize")>
			<cfset ARGUMENTS.serviceArguments["pageSize"] = Max(APPLICATION.controller.getSetting("PAGINATION_DEFAULT_PAGE_SIZE", 10) , 1) />
		<cfelse>
			<cfset ARGUMENTS.serviceArguments["pageSize"] = Max(ARGUMENTS.serviceArguments["pageSize"], 1) />
		</cfif>

	</cffunction>

</cfcomponent>