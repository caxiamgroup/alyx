<cfcomponent name="default" extends="default">

	<cffunction name="init">
		<cfset StructAppend(this, ARGUMENTS) />
		<cfreturn this />
	</cffunction>

	<cffunction name="renderFirstPage">
		<cfoutput>
			<a title="First" class="first" href="?#ARGUMENTS.parsedUrlparams#">&nbsp;</a>
		</cfoutput>
	</cffunction>

	<cffunction name="renderPreviousPage">
		<cfoutput>
			<a title="Previous" class="previous" href="?#ARGUMENTS.parsedUrlparams#">&nbsp;</a>
		</cfoutput>
	</cffunction>

	<cffunction name="renderNexPage">
		<cfoutput>
			<a title="Next" class="next" href="?#ARGUMENTS.parsedUrlparams#">&nbsp;</a>
		</cfoutput>
	</cffunction>

	<cffunction name="renderLastPage">
		<cfoutput>
			<a title="Last" class="last" href="?#ARGUMENTS.parsedUrlparams#">&nbsp;</a>
		</cfoutput>
	</cffunction>

	<cffunction name="renderPage">
		<cfoutput>#link#</cfoutput>
	</cffunction>

	<cffunction name="renderRecordPerPage">
		<cfset var local = StructNew() />
		<cfset local.displayCountID = "displaycount" & createUUID() >
		<cfoutput>
			<label>Click column headers to re-sort</label>
			<div class="select-menu" style="float:right; width: 50px; padding: 0px 0px 0px 5px; position:relative; position: relative; top: -3px;"><a href="##" class="select-btn"><span></span>#ARGUMENTS.pageSize#</a>
				<ul style="background:white; width: 50px; min-width: 50px;">
					<cfloop array="#ARGUMENTS.intervalLinks#" index="local.intervalLink">
						<li>#local.intervalLink#</li>
					</cfloop>
				</ul>
			</div>
			<label>per page</label>
		</cfoutput>
	</cffunction>

	<cffunction name="getSortOrderClass">
		<cfreturn ARGUMENTS.sortOrder EQ 'ASC'?"headerSortUp":"headerSortDown" />
	</cffunction>

</cfcomponent>