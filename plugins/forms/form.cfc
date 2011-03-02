<cfcomponent name="Form" output="no">

	<cffunction name="init" output="no">
		<cfargument name="name" required="yes"/>
		<cfset variables.rc = application.controller.getContext()/>
		<cfset variables.name = arguments.name/>
		<cfset variables.errors = ArrayNew(1)/>
		<cfset variables.successMessage = ""/>
		<cfset variables.overrideSubmitted = false/>
		<cfset variables.showClientSideValidationScript = true/>
		<cfset variables.encType = ""/>
        <cfset variables.useFieldset = true />
		<cfset resetFields()/>
		<cfreturn this/>
	</cffunction>

	<cffunction name="getName" output="no">
		<cfreturn variables.name/>
	</cffunction>

	<cffunction name="resetFields" output="no">
		<cfset variables.fields = StructNew()/>
		<cfset variables.fieldOrder = ArrayNew(1)/>
		<cfset variables.fieldDependencies = ArrayNew(1)/>
	</cffunction>

	<cffunction name="addField" output="no">
		<cfargument name="name"         required="yes"/>
		<cfargument name="label"        required="yes"/>
		<cfargument name="type"         required="yes"/>
		<cfargument name="required"     default="no"/>
		<cfargument name="defaultValue" default=""/>

		<cfset var field = Duplicate(arguments)/>

		<cfset field.dataset = ""/>

		<cfset variables.fields[arguments.name] = field/>
		<cfset ArrayAppend(variables.fieldOrder, field)/>

		<cfparam name="variables.rc[""#getFieldName(arguments.name)#""]" default="#arguments.defaultValue#"/>

		<cfif arguments.type eq "file">
			<cfset variables.encType = "multipart/form-data"/>
		</cfif>
	</cffunction>

	<cffunction name="removeField" output="no">
		<cfargument name="name" required="yes"/>

		<cfset var index = ""/>

		<cfif StructKeyExists(variables.fields, arguments.name)>
			<cfset StructDelete(variables.fields, arguments.name)/>

			<cfloop from="1" to="#ArrayLen(variables.fieldOrder)#" index="index">
				<cfif variables.fieldOrder[index].name eq arguments.name>
					<cfset ArrayDeleteAt(variables.fieldOrder, index)/>
					<cfbreak/>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="setFieldDataset" output="no">
		<cfargument name="name"       required="yes"/>
		<cfargument name="data"       default=""/>
		<cfargument name="type"       default=""/>
		<cfargument name="delimiters" default=","/>
		<cfargument name="idField"    default="id"/>
		<cfargument name="labelField" default="label"/>
		<cfargument name="dataset"    default=""/>

		<cfif IsSimpleValue(arguments.dataset)>
			<cfset arguments.dataset = application.controller.getPlugin("forms").createDataset(argumentCollection = arguments)/>
		</cfif>

		<cfset variables.fields[arguments.name].dataset = arguments.dataset/>
	</cffunction>

	<cffunction name="getFieldDataset" output="no">
		<cfargument name="name" required="yes"/>
		<cfreturn variables.fields[arguments.name].dataset/>
	</cffunction>

	<cffunction name="setFieldType" output="no">
		<cfargument name="name"       required="yes"/>
		<cfargument name="type"       default=""/>

		<cfset variables.fields[arguments.name].type = arguments.type/>
	</cffunction>

	<cffunction name="addDependency" output="no">
		<cfargument name="type"     required="yes"/>
		<cfargument name="fields"   default=""/>
		<cfargument name="errorMsg" default=""/>

		<cfset ArrayAppend(variables.fieldDependencies, arguments)/>
	</cffunction>

	<cffunction name="wasSubmitted" output="no">
		<cfreturn variables.overrideSubmitted or StructKeyExists(variables.rc, "form_" & variables.name)/>
	</cffunction>

	<cffunction name="setSubmitted" output="no">
		<cfset variables.overrideSubmitted = true/>
	</cffunction>

	<cffunction name="getFieldName" output="no">
		<cfargument name="name" required="yes"/>
		<cfreturn variables.name & "_" & arguments.name/>
	</cffunction>

	<cffunction name="getFieldNames" output="no">
		<cfargument name="regEx" default="" />

		<cfset var local = StructNew() />
		<cfset local.fieldNames = "" />

		<cfloop array="#variables.fieldOrder#" index="local.field">
			<cfset local.fieldName = local.field.name/>
			<cfif not Len(arguments.regEx) OR REFind(arguments.regEx, local.fieldName)>
				<cfset local.fieldNames = ListAppend(local.fieldNames, local.fieldName) />
			</cfif>
		</cfloop>

		<cfreturn local.fieldNames />
	</cffunction>

	<cffunction name="getFormFieldNames" output="no">
		<cfargument name="regEx" default="" />

		<cfset var local = StructNew() />
		<cfset local.fieldNames = "" />

		<cfset local.prefixLen = Len(variables.name) />

		<cfloop index="local.fieldName" list="#form.fieldNames#">
			<cfif Left(local.fieldName, local.prefixLen) eq variables.name>
				<cfset local.fieldName = RemoveChars(local.fieldName, 1, local.prefixLen + 1) />
				<cfif not Len(arguments.regEx) OR REFind(arguments.regEx, local.fieldName)>
					<cfset local.fieldNames = ListAppend(local.fieldNames, local.fieldName) />
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn local.fieldNames />
	</cffunction>

	<cffunction name="getFieldValue" output="no">
		<cfargument name="name" required="yes"/>

		<cfset var value = ""/>
		<cfset var fieldName = getFieldName(arguments.name)/>
		<cfif StructKeyExists(variables.rc, fieldName)>
			<cfset value = Trim(variables.rc[fieldName])/>
		</cfif>
		<cfreturn value/>
	</cffunction>

	<cffunction name="setFieldValue" output="no">
		<cfargument name="name" required="yes"/>
		<cfargument name="value" required="yes"/>
		<cfset variables.rc[getFieldName(arguments.name)] = arguments.value/>
	</cffunction>

	<cffunction name="fieldExists" output="no">
		<cfargument name="name" required="yes"/>
		<cfreturn StructKeyExists(variables.fields, arguments.name)>
	</cffunction>

	<cffunction name="populateFromBean" output="no">
		<cfargument name="bean" required="yes"/>
		<cfargument name="prefix" default=""/>
		<cfset var local = StructNew()/>
		<cfloop array="#variables.fieldOrder#" index="local.field">
			<cfset local.fieldName = local.field.name/>
			<cfif Len(arguments.prefix)>
				<cfset local.fieldName = ReplaceNoCase(local.fieldName, arguments.prefix, "")/>
			</cfif>
			<cfif not StructKeyExists(arguments.bean, "get#local.fieldName#")>
				<!--- Field names such as "subscriber_firstName" are rewritten as "getSubscriberFirstName" in the model (without the underscore) --->
				<cfset local.fieldName = Replace(local.field.name, "_", "", "all")/>
				<cfif Len(arguments.prefix)>
					<cfset local.fieldName = ReplaceNoCase(local.fieldName, arguments.prefix, "")/>
				</cfif>
			</cfif>

			<cfif StructKeyExists(arguments.bean, "get#local.fieldName#")>
				<cfinvoke component="#arguments.bean#" method="get#local.fieldName#" returnVariable="local.beanValue"/>
				<cfif NOT StructKeyExists(local, "beanValue")>
					<cfset local.beanValue = "" />
				</cfif>
				<cfset setFieldValue(local.field.name, local.beanValue)/>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="populateBean" output="no">
		<cfargument name="bean" required="yes"/>
		<cfargument name="prefix" default=""/>
		<cfset var local = StructNew()/>
		<cfloop array="#variables.fieldOrder#" index="local.field">
			<cfset local.fieldName = local.field.name/>
			<cfif Len(arguments.prefix)>
				<cfset local.fieldName = ReplaceNoCase(local.fieldName, arguments.prefix, "")/>
			</cfif>
			<cfif not StructKeyExists(arguments.bean, "set#local.fieldName#")>
				<!--- Field names such as "subscriber_firstName" are rewritten as "setSubscriberFirstName" in the model (without the underscore) --->
				<cfset local.fieldName = Replace(local.field.name, "_", "", "all")/>
				<cfif Len(arguments.prefix)>
					<cfset local.fieldName = ReplaceNoCase(local.fieldName, arguments.prefix, "")/>
				</cfif>
			</cfif>

			<cfif StructKeyExists(arguments.bean, "set#local.fieldName#")>
				<cfif Len(arguments.prefix)>
					<cfinvoke component="#arguments.bean#" method="set#local.fieldName#">
						<cfinvokeargument name="#local.fieldName#" value="#getFieldValue(local.field.name)#"/>
					</cfinvoke>
				<cfelse>
					<cfinvoke component="#arguments.bean#" method="set#local.fieldName#">
						<cfinvokeargument name="#local.field.name#" value="#getFieldValue(local.field.name)#"/>
					</cfinvoke>
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>

	<cffunction name="validate" output="no">
		<cfset var local = StructNew()/>
		<cfset local.formsPlugin = application.controller.getPlugin("forms")/>
		<cfset variables.errors = ArrayNew(1)/>

		<!--- Validate individual fields --->
		<cfloop array="#variables.fieldOrder#" index="local.field">
			<cfset local.validator = local.formsPlugin.getValidator(local.field.type)/>
			<cfset local.field.errors = ArrayNew(1)/>
			<cfset local.validator.validate(local.field, getFieldValue(local.field.name))/>
			<cfloop array="#local.field.errors#" index="local.error">
				<cfset ArrayAppend(variables.errors, local.error)/>
			</cfloop>
		</cfloop>

		<!--- Validate field dependencies --->
		<cfloop array="#variables.fieldDependencies#" index="local.dependency">
			<cfset local.validator = local.formsPlugin.getDependencyValidator(local.dependency.type)/>
			<cfset local.validator.validate(this, local.dependency)/>
		</cfloop>
	</cffunction>

	<cffunction name="getFields" output="no">
		<cfreturn variables.fieldOrder/>
	</cffunction>

	<cffunction name="getField" output="no">
		<cfargument name="name" required="yes"/>
		<cfreturn variables.fields[arguments.name]/>
	</cffunction>

	<cffunction name="hasErrors" output="no">
		<cfreturn not ArrayIsEmpty(variables.errors)/>
	</cffunction>

	<cffunction name="fieldHasErrors" output="no">
		<cfargument name="name" required="yes"/>
		<cfreturn StructKeyExists(variables.fields[arguments.name], "errors") and not ArrayIsEmpty(variables.fields[arguments.name].errors)/>
	</cffunction>

	<cffunction name="getErrors" output="no">
		<cfreturn variables.errors/>
	</cffunction>

	<cffunction name="setErrors" output="no">
		<cfargument name="errors" required="yes"/>
		<cfset variables.errors = arguments.errors/>
	</cffunction>

	<cffunction name="hasSuccessMessage" output="no">
		<cfreturn Len(variables.successMessage)/>
	</cffunction>

	<cffunction name="getSuccessMessage" output="no">
		<cfreturn variables.successMessage/>
	</cffunction>

	<cffunction name="setSuccessMessage" output="no">
		<cfargument name="successMessage" required="yes"/>
		<cfset variables.successMessage = arguments.successMessage/>
	</cffunction>

	<cffunction name="start" output="no">
		<cfargument name="action"       default="#request.context.action#"/>
		<cfargument name="method"       default="post"/>
		<cfargument name="extra"        default=""/>
		<cfargument name="autocomplete" default=""/>
		<cfargument name="onSubmit"     default="return validateForm(this)"/>
        <cfargument name="useFieldset"  default="#variables.useFieldset#">

        <cfset variables.useFieldset = arguments.useFieldset />

		<cfif !FindNoCase(".cfm", arguments.action)>
			<cfif ListFirst(arguments.action,".") eq "general">
				<cfset arguments.action = ListRest(arguments.action, ".") />
			</cfif>
			<cfset arguments.action = "/" & ListChangeDelims(arguments.action, "/", ".") & ".cfm" />
		</cfif>

		<cfif arguments.autocomplete eq false>
			<cfset arguments.extra &= " autocomplete=""off"""/>
		</cfif>

		<cfif Len(arguments.onSubmit)>
			<cfset arguments.extra &= " onsubmit=""" & arguments.onSubmit & """"/>
		</cfif>

		<cfif Len(variables.encType)>
			<cfset arguments.extra &= " enctype=""" & variables.encType & """"/>
		</cfif>

		<cfif Len(Trim(arguments.extra))>
			<cfset arguments.extra = " " & Trim(arguments.extra)/>
		</cfif>

		<cfset variables.started = true/>

        <cfset local.result = "<form action=""#arguments.action#"" id=""#variables.name#"" method=""#arguments.method#""#arguments.extra#>" />

        <cfif variables.useFieldset>
              <cfset local.result &= "<fieldset>" />
        </cfif>

        <cfset local.result &= "<input type=""hidden"" name=""form_#variables.name#"" value=""""/>" />

		<cfreturn local.result/>
	</cffunction>

	<cffunction name="end" output="no">
        <cfset var formEnd = "</form>" />

        <cfif variables.useFieldset>
            <cfset formEnd = "</fieldset>" & formEnd />
        </cfif>

		<cfreturn formEnd />
	</cffunction>

	<cffunction name="isStarted" output="no">
		<cfreturn StructKeyExists(variables, "started") and variables.started eq true/>
	</cffunction>

	<cffunction name="label" output="no">
		<cfargument name="name"          required="yes"/>
		<cfargument name="label"         default="#variables.fields[ListFirst(arguments.name)].label#"/>
		<cfargument name="required"      default="#variables.fields[ListFirst(arguments.name)].required#"/>
		<cfargument name="for"           default="#ListFirst(arguments.name)#"/>
		<cfargument name="id"            default=""/>
		<cfargument name="extra"         default=""/>
		<cfargument name="errorClass"    default=""/>
		<cfargument name="requiredClass" default=""/>
		<cfargument name="beforeLabel"   default=""/>
		<cfargument name="afterLabel"    default=""/>

		<cfset var local = StructNew()/>
		<cfset local.hasErrors = false/>
		<cfset local.classes = ""/>

		<cfloop list="#arguments.name#" index="local.fieldName">
			<cfset local.field = variables.fields[local.fieldName]/>
			<cfif StructKeyExists(local.field, "errors") and ArrayLen(local.field.errors)>
				<cfset local.hasErrors = true/>
				<cfbreak/>
			</cfif>
		</cfloop>

		<cfset local.fieldId = variables.name & "_" & arguments.for/>

		<cfif local.hasErrors>
			<cfif not Len(arguments.errorClass)>
				 <cfset arguments.errorClass = application.controller.getSetting("formFieldErrorClass", "error")/>
			</cfif>

			<cfif Len(arguments.errorClass)>
				<cfset local.classes &= " " & arguments.errorClass/>
			</cfif>
		</cfif>

		<cfif Len(arguments.id)>
			<cfif IsBoolean(arguments.id) and arguments.id eq true>
				<cfset arguments.extra &= " id=""label-" & local.fieldId & """"/>
			<cfelse>
				<cfset arguments.extra &= " id=""" & arguments.id & """"/>
			</cfif>
		</cfif>

		<cfif arguments.required>
			<cfif not Len(arguments.requiredClass)>
				<cfset arguments.requiredClass = application.controller.getSetting("formFieldRequiredClass", "required")/>
			</cfif>
			<cfset local.classes &= " " & arguments.requiredClass/>
		</cfif>

		<cfif Len(local.classes)>
			<cfif FindNoCase("class=", arguments.extra)>
				<cfset arguments.extra = Replace(arguments.extra, "class=""", "class=""" & Trim(local.classes) & " ")/>
			<cfelse>
				<cfset arguments.extra &= " class=""" & Trim(local.classes) & """"/>
			</cfif>
		</cfif>

		<cfif Len(Trim(arguments.extra))>
			<cfset arguments.extra = " " & Trim(arguments.extra)/>
		</cfif>

		<cfset local.output = "<label for=""#local.fieldId#""#arguments.extra#>#arguments.beforeLabel##arguments.label##arguments.afterLabel#</label>"/>

		<cfreturn local.output/>
	</cffunction>

	<cffunction name="addError" output="no" hint="Manually add an error message.">
		<cfargument name="error"  required="yes"/>
		<cfargument name="fields" default=""/>
		<cfset var local = StructNew()/>
		<cfset ArrayAppend(variables.errors, arguments.error)/>
		<cfif IsArray(arguments.fields)>
			<cfloop array="#arguments.fields#" index="local.fieldName">
				<cfset ArrayAppend(variables.fields[local.fieldName].errors, arguments.error)/>
			</cfloop>
		<cfelse>
			<cfloop list="#arguments.fields#" index="local.fieldName">
				<cfset ArrayAppend(variables.fields[local.fieldName].errors, arguments.error)/>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="addErrors" output="no" hint="Add error messages from another form object.">
		<cfargument name="errors"  required="yes"/>
		<cfset var local = StructNew()/>
		<cfloop array="#arguments.errors#" index="local.error">
			<cfset ArrayAppend(variables.errors, local.error)/>
		</cfloop>
	</cffunction>

	<cffunction name="displayErrors" output="no">
		<cfargument name="title" default="The following problems were found:"/>
		<cfargument name="open"  default=""/>
		<cfargument name="close" default=""/>
		<cfset var local = StructNew()/>

		<cfset local.output = '<div id="error-message-#getName()#">'/>
		<cfif hasErrors()>
		<cfset local.output &= '<div class="msg error">'/>
			<cfset local.output &= arguments.open/>
			<cfif Len(arguments.title)>
				<cfset local.output &= "<p>" & arguments.title & "</p>"/>
			</cfif>
			<cfset local.output &= "<ul>"/>
			<cfloop array="#variables.errors#" index="local.error">
				<cfset local.output &= "<li>#local.error#</li>"/>
			</cfloop>
			<cfset local.output &= "</ul>" & arguments.close/>
			<cfset local.output &= '</div>'/>
		</cfif>
		<cfset local.output &= '</div>'/>
		<cfreturn local.output/>
	</cffunction>

	<cffunction name="displaySuccessMessage" output="no">
		<cfargument name="open"  default=""/>
		<cfargument name="close" default=""/>
		<cfset var local = StructNew()/>
		<cfset local.output = ""/>
		<cfif hasSuccessMessage()>
			<cfset local.output = '<div class="msg success">'/>
			<cfset local.output &= arguments.open/>
			<cfset local.output &= "<ul>"/>
				<cfset local.output &= "<li>#getSuccessMessage()#</li>"/>
			<cfset local.output &= "</ul>" & arguments.close/>
			<cfset local.output &= '</div>'/>
		</cfif>
		<cfreturn local.output/>
	</cffunction>

	<cffunction name="displayMessages" output="no">
		<cfargument name="errorTitle" default="The following problems were found:" />
		<cfargument name="errorOpen" default="" />
		<cfargument name="errorClose" default=""/>
		<cfargument name="successOpen" default="" />
		<cfargument name="successClose" default="" />
		<cfset var local = StructNew()/>
		<cfset local.output = ""/>
		<cfif hasSuccessMessage()>
			<cfset local.output = displaySuccessMessage(open=arguments.successOpen, close=arguments.successClose) />
		<cfelse>
			<cfset local.output = displayErrors(title=arguments.errorTitle, open=arguments.errorOpen, close=arguments.errorClose) />
		</cfif>
		<cfreturn local.output/>
	</cffunction>

	<cffunction name="renderField" output="no">
		<cfargument name="name"     required="yes"/>
		<cfargument name="type"     required="yes"/>
		<cfargument name="field"    default="#variables.fields[arguments.name]#"/>
		<cfargument name="form"     default="#this#"/>

		<cfset var renderer = application.controller.getPlugin("forms").getRenderer(arguments.type)/>
		<cfreturn renderer.render(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="setShowClientSideValidationScript" output="no">
		<cfargument name="show" required="yes"/>
		<cfset variables.showClientSideValidationScript = arguments.show>
	</cffunction>

	<cffunction name="getShowClientSideValidationScript" output="no">
		<cfreturn variables.showClientSideValidationScript and ArrayLen(variables.fieldOrder) gt 0>
	</cffunction>

	<cffunction name="getClientSideValidationScript" output="no">
		<cfargument name="context" required="yes"/>
		<cfset var local = StructNew()/>
		<cfset local.formsPlugin = application.controller.getPlugin("forms")/>
		<!--- Validate field dependencies --->
		<cfloop array="#variables.fieldDependencies#" index="local.dependency">
			<cfset local.validator = local.formsPlugin.getDependencyValidator(local.dependency.type)/>
			<cfset local.validator.getClientSideValidationScript(this, local.dependency, arguments.context)/>
		</cfloop>
	</cffunction>

	<cffunction name="serialize" output="no" hint="Creates a structure of field names and their values. Does not store field type or validation info.">
		<cfset var local = StructNew()/>
		<cfset local.data = StructNew()/>
		<cfloop array="#variables.fieldOrder#" index="local.field">
			<cfset local.data[local.field.name] = getFieldValue(local.field.name)/>
		</cfloop>
		<cfreturn local.data/>
	</cffunction>

	<cffunction name="deserialize" output="no" hint="Restores field values from a previous 'serialize' operation.">
		<cfargument name="data" required="yes"/>
		<cfset var field = ""/>
		<cfloop collection="#arguments.data#" item="field">
			<cfif StructKeyExists(variables.fields, field)>
				<cfset setFieldValue(field, arguments.data[field])/>
			</cfif>
		</cfloop>
	</cffunction>

	<!--- ---------------Private Functions --------------- --->

	<cffunction name="OnMissingMethod" output="no">
		<cfargument name="missingMethodName"      required="yes"/>
		<cfargument name="missingMethodArguments" required="yes"/>

		<cfif CompareNoCase(Left(arguments.missingMethodName, 6), "render") eq 0>
			<cfset arguments.missingMethodArguments.type = Right(arguments.missingMethodName, Len(arguments.missingMethodName) - 6)/>
			<cfreturn renderField(argumentCollection = arguments.missingMethodArguments)/>
		</cfif>

		<cfreturn ""/>
	</cffunction>

</cfcomponent>