<cfcomponent name="forms" hint="Common forms plugin" output="false">

	<cffunction name="init" access="public" output="false">
		<cfset variables.formComponentLocation = application.controller.getSetting("customFormComponentLocation", "/alyx.plugins.forms.form")/>

		<cfset initValidationTypes()/>
		<cfset initValidationDependencies()/>
		<cfset initDisplayTypes()/>

		<cfreturn this/>
	</cffunction>

	<cffunction name="initValidationTypes" access="private" output="no">
		<cfset var local = StructNew()/>
		<cfset variables.validationTypes = StructNew()/>
		<cfset scanValidationTypeLocation(location = "/alyx/plugins/forms/validationtypes")/>

		<cfset local.customLocations = application.controller.getSetting("customFormValidationTypeLocations")/>
		<cfif IsArray(local.customLocations)>
			<cfloop array="#local.customLocations#" index="local.location">
				<cfset scanValidationTypeLocation(location = local.location)/>
			</cfloop>
		<cfelseif Len(local.customLocations)>
			<cfset scanValidationTypeLocation(location = local.customLocations)/>
		</cfif>
	</cffunction>

	<cffunction name="scanValidationTypeLocation" access="private" output="no">
		<cfargument name="location" required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.path = ExpandPath(arguments.location)/>
		<cfset local.comPath = ListChangeDelims(ReReplace(arguments.location, "^\/", ""), ".", "/")/>
		<cfif DirectoryExists(local.path)>
			<cfdirectory action="list" directory="#local.path#" name="local.files" type="file"/>
			<cfloop query="local.files">
				<cfif Left(local.files.name, 1) neq "_">
					<cfset registerValidationType(ReReplace(local.files.name, ".cfc$", ""), local.comPath)/>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="registerValidationType" output="no">
		<cfargument name="name" required="yes"/>
		<cfargument name="path" required="yes"/>
		<cfset variables.validationTypes[arguments.name] = CreateObject("component", arguments.path & "." & arguments.name).init()/>
	</cffunction>

	<cffunction name="initValidationDependencies" access="private" output="no">
		<cfset var local = StructNew()/>
		<cfset variables.validationDependencies = StructNew()/>
		<cfset scanValidationDependencyLocation(location = "/alyx/plugins/forms/validationdependencies")/>

		<cfset local.customLocations = application.controller.getSetting("customFormValidationDependencyLocations")/>
		<cfif IsArray(local.customLocations)>
			<cfloop array="#local.customLocations#" index="local.location">
				<cfset scanValidationDependencyLocation(location = local.location)/>
			</cfloop>
		<cfelseif Len(local.customLocations)>
			<cfset scanValidationDependencyLocation(location = local.customLocations)/>
		</cfif>
	</cffunction>

	<cffunction name="scanValidationDependencyLocation" access="private" output="no">
		<cfargument name="location" required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.path = ExpandPath(arguments.location)/>
		<cfset local.comPath = ListChangeDelims(ReReplace(arguments.location, "^\/", ""), ".", "/")/>
		<cfif DirectoryExists(local.path)>
			<cfdirectory action="list" directory="#local.path#" name="local.files" type="file"/>
			<cfloop query="local.files">
				<cfif Left(local.files.name, 1) neq "_">
					<cfset registerValidationDependency(ReReplace(local.files.name, ".cfc$", ""), local.comPath)/>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="registerValidationDependency" output="no">
		<cfargument name="name" required="yes"/>
		<cfargument name="path" required="yes"/>
		<cfset variables.validationDependencies[arguments.name] = CreateObject("component", arguments.path & "." & arguments.name).init()/>
	</cffunction>

	<cffunction name="InitDisplayTypes" access="private" output="no">
		<cfset var local = StructNew()/>
		<cfset variables.displayTypes = StructNew()/>
		<cfset scanDisplayTypeLocation(location = "/alyx/plugins/forms/displaytypes")/>

		<cfset local.customLocations = application.controller.getSetting("customFormFieldDisplayTypeLocations")/>
		<cfif IsArray(local.customLocations)>
			<cfloop array="#local.customLocations#" index="local.location">
				<cfset scanDisplayTypeLocation(location = local.location)/>
			</cfloop>
		<cfelseif Len(local.customLocations)>
			<cfset scanDisplayTypeLocation(location = local.customLocations)/>
		</cfif>
	</cffunction>

	<cffunction name="scanDisplayTypeLocation" access="private" output="no">
		<cfargument name="location" required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.path = ExpandPath(arguments.location)/>
		<cfset local.comPath = ListChangeDelims(ReReplace(arguments.location, "^\/", ""), ".", "/")/>

		<cfif DirectoryExists(local.path)>
			<cfdirectory action="list" directory="#local.path#" name="local.files" type="file"/>
			<cfloop query="local.files">
				<cfif Left(local.files.name, 1) neq "_">
					<cfset registerDisplayType(ReReplace(local.files.name, ".cfc$", ""), local.comPath)/>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="registerDisplayType" output="no">
		<cfargument name="name" required="yes"/>
		<cfargument name="path" required="yes"/>
		<cfset variables.displayTypes[arguments.name] = CreateObject("component", arguments.path & "." & arguments.name).init()/>
	</cffunction>

	<cffunction name="getForm" output="no">
		<cfargument name="name" required="yes"/>

		<cfset var rc = application.controller.getContext()/>

		<cfif not StructKeyExists(rc, "forms")>
			<cfset rc.forms = StructNew()/>
		</cfif>

		<cfif not StructKeyExists(rc.forms, arguments.name)>
			<cfset rc.forms[arguments.name] = CreateObject("component", variables.formComponentLocation).init(name = arguments.name)/>
		</cfif>

		<cfreturn rc.forms[arguments.name]/>
	</cffunction>

	<cffunction name="getValidator" output="no">
		<cfargument name="type" required="yes"/>
		<cfreturn variables.validationTypes[arguments.type]/>
	</cffunction>

	<cffunction name="getDependencyValidator" output="no">
		<cfargument name="type" required="yes"/>
		<cfreturn variables.validationDependencies[arguments.type]/>
	</cffunction>

	<cffunction name="getRenderer" output="no">
		<cfargument name="type" required="yes"/>
		<cfreturn variables.displayTypes[arguments.type]/>
	</cffunction>

	<cffunction name="getClientSideValidationScript" output="no">
		<cfset var local = StructNew()/>

		<cfset local.rc = application.controller.getContext()/>

		<cfif not StructKeyExists(local.rc, "forms")>
			<cfreturn ""/>
		</cfif>

		<cfset local.validationHelpers = StructNew()/>

		<cfset local.output = CreateObject("java", "java.lang.StringBuffer")/>

		<cfset local.hasContent = false/>
		<cfset local.output.append('<script type="text/javascript">var ')/>

		<cfloop collection="#local.rc.forms#" item="local.formName">
			<cfset local.form = local.rc.forms[local.formName]/>
			<cfif local.form.getShowClientSideValidationScript()>
				<cfset local.hasContent = true/>
				<cfset local.fields = local.form.getFields()/>
				<cfset local.output.append("formRef=new FormValidation('" & local.formName & "');")/>
				<cfloop array="#local.fields#" index="local.field">
					<cfif local.field.required eq true>
						<cfset local.required = 1/>
					<cfelse>
						<cfset local.required = 0/>
					</cfif>
					<cfset local.output.append("formRef.addField('" & local.field.name & "'," & local.required & ");")/>
				</cfloop>
				<cfset local.output.append("formRef.validate=function(){this.clearErrorMessages();")/>
				<cfloop array="#local.fields#" index="local.field">
					<cfset local.validator = getValidator(local.field.type)/>
					<cfset local.validator.getClientSideValidationScript(field = local.field, context = local)/>
				</cfloop>
				<cfset local.form.getClientSideValidationScript(context = local)/>
				<cfset local.output.append("return this.onValidationComplete();};")/>
				<cfset local.output.append("validationForms['" & local.formName & "']=formRef;")/>
				<cfset local.output.append("function getErrorHeading(){return '" & JSStringFormat(HtmlEditFormat(application.controller.getPlugin("snippets").getSnippet("errorheading", "errormessages"))) & "'};")/>
			</cfif>
		</cfloop>

		<cfif local.hasContent>
			<cfloop collection="#local.validationHelpers#" item="local.helper">
				<cfset local.output.append(Trim(local.validationHelpers[local.helper]))/>
			</cfloop>

			<cfset local.output.append("</script>")/>
			<cfreturn local.output.toString()/>
		</cfif>

		<cfreturn ""/>
	</cffunction>

	<cffunction name="displayErrors" output="no" hint="Displays errors for all forms.">
		<cfargument name="open"  default=""/>
		<cfargument name="close" default=""/>
		<cfset var local = StructNew()/>
		<cfset local.output = ""/>
		<cfset local.rc = application.controller.getContext()/>
		<cfif StructKeyExists(local.rc, "forms")>
			<cfloop collection="#local.rc.forms#" item="local.formName">
				<cfset local.output &= local.rc.forms[local.formName].displayErrors(argumentCollection = arguments)/>
			</cfloop>
		</cfif>
		<cfreturn local.output/>
	</cffunction>

	<cffunction name="displaySuccessMessage" output="no" hint="Displays success messages for all forms.">
		<cfargument name="open"  default=""/>
		<cfargument name="close" default=""/>
		<cfset var local = StructNew()/>
		<cfset local.output = ""/>
		<cfset local.rc = application.controller.getContext()/>
		<cfif StructKeyExists(local.rc, "forms")>
			<cfloop collection="#local.rc.forms#" item="local.formName">
				<cfset local.output &= local.rc.forms[local.formName].displaySuccessMessage(argumentCollection = arguments)/>
			</cfloop>
		</cfif>
		<cfreturn local.output/>
	</cffunction>

	<cffunction name="displayMessages" output="no" hint="Displays all messages for all forms.">
		<cfargument name="errorTitle" default="The following problems were found:"/>
		<cfargument name="errorOpen" default=""/>
		<cfargument name="errorClose" default=""/>
		<cfargument name="successOpen" default=""/>
		<cfargument name="successClose" default=""/>
		<cfset var local = StructNew()/>
		<cfset local.output = ""/>
		<cfset local.rc = application.controller.getContext()/>
		<cfif StructKeyExists(local.rc, "forms")>
			<cfloop collection="#local.rc.forms#" item="local.formName">
				<cfset local.output &= local.rc.forms[local.formName].displayMessages(argumentCollection = arguments)/>
			</cfloop>
		</cfif>
		<cfreturn local.output/>
	</cffunction>

	<cffunction name="wasFormSubmitted" output="no">
		<cfargument name="name" required="yes"/>
		<cfreturn StructKeyExists(form, "form_" & arguments.name)/>
	</cffunction>

	<cffunction name="createDataset" output="no">
		<cfargument name="data"       default=""/>
		<cfargument name="type"       default=""/>
		<cfargument name="delimiters" default=","/>
		<cfargument name="idField"    default="id"/>
		<cfargument name="labelField" default="label"/>

		<cfset var local = StructNew()/>
		<cfset local.dataset = ""/>

		<cfif Len(arguments.type)>
			<cfset arguments.data = getDataSetDataByType(type = arguments.type, idField = arguments.idField, labelField = arguments.labelField)/>
		</cfif>

		<cfif not IsSimpleValue(arguments.data) or Len(arguments.data)>
			<cfif IsQuery(arguments.data)>
				<cfset local.dataset = CreateObject("component", "forms.datasetQuery").init(argumentCollection = arguments)/>
			<cfelseif IsArray(arguments.data)>
				<cfif ArrayLen(arguments.data) and IsObject(arguments.data[1])>
					<cfset local.dataset = CreateObject("component", "forms.datasetBean").init(argumentCollection = arguments)/>
				<cfelseif ArrayLen(arguments.data) and IsStruct(arguments.data[1])>
					<cfset local.dataset = CreateObject("component", "forms.datasetStructArray").init(argumentCollection = arguments)/>
				<cfelse>
					<cfset local.dataset = CreateObject("component", "forms.datasetArray").init(argumentCollection = arguments)/>
				</cfif>
			<cfelseif IsSimpleValue(arguments.data)>
				<cfif Find("|", arguments.data)>
					<cfset local.data = ArrayNew(1)/>
					<cfloop list="#arguments.data#" index="local.group">
						<cfset local.temp = {id = ListFirst(local.group, "|"), label = ListRest(local.group, "|")}/>
						<cfset ArrayAppend(local.data, local.temp)/>
					</cfloop>
					<cfset arguments.data = local.data/>
					<cfset local.dataset = CreateObject("component", "forms.datasetStructArray").init(argumentCollection = arguments)/>
				<cfelse>
					<cfset arguments.data = ListToArray(arguments.data, arguments.delimiters)/>
					<cfset local.dataset = CreateObject("component", "forms.datasetArray").init(argumentCollection = arguments)/>
				</cfif>
			</cfif>
		</cfif>

		<cfif IsSimpleValue(local.dataset)>
			<cfthrow message="Unknown dataset type. Must be a query, array, or pre-defined snippet."/>
		</cfif>

		<cfreturn local.dataset/>
	</cffunction>

	<cffunction name="getDataSetDataByType" access="private" output="no">
		<cfargument name="type"       required="yes"/>
		<cfargument name="idField"    default="id"/>
		<cfargument name="labelField" default="label"/>

		<cfset var local = StructNew()/>
		<cfset local.data = ""/>
		<cfset local.snippetsPlugin = application.controller.getPlugin("snippets")/>

		<cfswitch expression="#ListFirst(arguments.type, ":")#">
			<cfcase value="state">
				<cfset local.data = ListToArray(local.snippetsPlugin.getSnippet("usa_states_short"))/>
			</cfcase>
			<cfcase value="stateVerbose">
				<cfset local.data = local.snippetsPlugin.getSnippet("usa_states_long")/>
			</cfcase>
			<cfcase value="country">
				<cfset local.data = local.snippetsPlugin.getSnippet("countries_long")/>
			</cfcase>
			<cfcase value="count">
				<cfset local.params = ListRest(arguments.type, ":")/>
				<cfif ListLen(local.params) eq 2>
					<cfset local.countFrom = ListGetAt(local.params, 1)/>
					<cfset local.countTo = ListGetAt(local.params, 2)/>
				<cfelse>
					<cfset local.countFrom = 1/>
					<cfset local.countTo = local.params/>
				</cfif>
				<cfif local.countFrom gt local.countTo>
					<cfset local.step = -1/>
				<cfelse>
					<cfset local.step = 1/>
				</cfif>
				<cfset local.data = ArrayNew(1)/>
				<cfloop from="#local.countFrom#" to="#local.countTo#" step="#local.step#" index="local.index">
					<cfset ArrayAppend(local.data, local.index)/>
				</cfloop>
			</cfcase>
			<cfcase value="yesno">
				<cfset local.data = ArrayNew(1)/>
				<cfset local.temp = {id = 1, label = "Yes"}/>
				<cfset ArrayAppend(local.data, local.temp)/>
				<cfset local.temp = {id = 0, label = "No"}/>
				<cfset ArrayAppend(local.data, local.temp)/>
			</cfcase>
			<cfcase value="monthNumeric">
				<cfset local.data = ListToArray("01,02,03,04,05,06,07,08,09,10,11,12")/>
			</cfcase>
			<cfcase value="monthNumericVerbose">
				<cfset local.data = "01|01 - January,02|02 - February,03|03 - March,04|04 - April,05|05 - May,06|06 - June,07|07 - July,08|08 - August,09|09 - September,10|10 - October,11|11 - November,12|12 - December"/>
			</cfcase>
			<cfcase value="monthNumericShort">
				<cfset local.data = "01|01 - Jan,02|02 - Feb,03|03 - Mar,04|04 - Apr,05|05 - May,06|06 - Jun,07|07 - Jul,08|08 - Aug,09|09 - Sep,10|10 - Oct,11|11 - Nov,12|12 - Dec"/>
			</cfcase>
			<cfcase value="dayNumeric">
				<cfset local.data = ListToArray("01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31")/>
			</cfcase>
			<cfcase value="gender">
				<cfset local.data = ArrayNew(1)/>
				<cfset local.temp = {id = "M", label = "Male"}/>
				<cfset ArrayAppend(local.data, local.temp)/>
				<cfset local.temp = {id = "F", label = "Female"}/>
				<cfset ArrayAppend(local.data, local.temp)/>
			</cfcase>
			<cfdefaultcase>
				<cfset local.data = ListToArray(local.snippetsPlugin.getSnippet(arguments.type))/>
			</cfdefaultcase>
		</cfswitch>

		<cfreturn local.data/>
	</cffunction>

</cfcomponent>