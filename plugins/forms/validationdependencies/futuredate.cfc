<cfcomponent output="no" extends="_common">

	<cffunction name="validate" output="no">
		<cfargument name="form"       required="yes"/>
		<cfargument name="params"     required="yes"/>

		<cfset var local = StructNew()/>
		<cfset local.fields = ArrayNew(1)/>

		<cfif StructKeyExists(arguments.params, "date")>
			<cfif not IsDate(arguments.params.date)>
				<!--- Date field validation should be completed elsewhere --->
				<cfreturn/>
			</cfif>
			
			<cfset local.date = arguments.params.date/>
		<cfelse>
			<cfset local.month = arguments.form.getFieldValue(arguments.params.month)/>
			<cfset local.year = arguments.form.getFieldValue(arguments.params.year)/>
	
			<cfif not IsNumeric(local.month) or local.month lt 1 or local.month gt 12 or not IsNumeric(local.year)>
				<!--- Individual date field validation should be completed elsewhere --->
				<cfreturn/>
			</cfif>
	
			<cfset ArrayAppend(local.fields, arguments.params.month)/>
			<cfset ArrayAppend(local.fields, arguments.params.year)/>
	
			<cfif StructKeyExists(arguments.params, "day")>
				<cfset local.day = arguments.form.getFieldValue(arguments.params.day)/>
	
				<cfif not IsNumeric(local.day) or local.day lt 1 or local.day gt DaysInMonth(local.month & "/1/" & local.year)>
					<!--- Individual date field validation should be completed elsewhere --->
					<cfreturn/>
				</cfif>
	
				<cfset ArrayAppend(local.fields, arguments.params.day)/>
			<cfelse>
				<cfset local.day = DaysInMonth(local.month & "/1/" & local.year)/>
			</cfif>
			
			<cfset local.date = local.month & "/" & local.day & "/" & local.year/>
		</cfif>
		
		<cfif DateDiff("d", Now(), local.date) lt 0>
			<cfset local.errorMsg = getErrorMessage("datefutureonly", arguments.params.errorMsg)/>
			<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", arguments.params.label)/>
			<cfset arguments.form.addError(local.errorMsg, local.fields)/>
		</cfif>
	</cffunction>

	<!--- -------------------- Client Side Validation -------------------- --->

	<cffunction name="getClientSideValidationScript" output="no">
		<cfargument name="form"    required="yes"/>
		<cfargument name="params"  required="yes"/>
		<cfargument name="context" required="yes"/>

		<cfset var local = StructNew()/>

		<cfif not StructKeyExists(arguments.context.validationHelpers, "futuredate")>
			<cfset arguments.context.validationHelpers.futuredate = "function validateFutureDate(form,date,year,month,day,errorMsg){var yearValue;var monthValue;var dayValue;if(date){var dateValue=form.getValue(date);if(form.fieldHasErrors(date)||dateValue.length==0){return}dateValue=new Date(dateValue);yearValue=dateValue.getFullYear();monthValue=dateValue.getMonth()+1;dayValue=dateValue.getDate()}else{yearValue=parseInt(form.getValue(year),10);monthValue=parseInt(form.getValue(month),10);if(day){dayValue=parseInt(form.getValue(day),10)}else{dayValue=31}if(form.fieldHasErrors(year)||form.fieldHasErrors(month)||isNaN(yearValue)||isNaN(monthValue)||isNaN(dayValue)){return}}var thisDate=new Date();var thisYear=thisDate.getFullYear();var thisMonth=thisDate.getMonth()+1;var thisDay=thisDate.getDate();if((yearValue<thisYear)||(yearValue==thisYear&&monthValue<thisMonth)||(yearValue==thisYear&&monthValue==thisMonth&&dayValue<thisDay)){form.addErrorMessages(errorMsg,[month,year])}}"/>
		</cfif>

		<cfset local.errorMsg = getErrorMessage("datefutureonly", arguments.params.errorMsg)/>
		<cfset local.errorMsg = Replace(local.errorMsg, "%%fieldname%%", arguments.params.label)/>
		<cfloop list="date,year,month,day" index="local.field">
			<cfif StructKeyExists(arguments.params, local.field)>
				<cfset local[local.field] = "'" & arguments.params[local.field] & "'"/>
			<cfelse>
				<cfset local[local.field] = "null"/>
			</cfif>
		</cfloop>
		<cfset arguments.context.output.append("validateFutureDate(this," & local.date & "," & local.year & "," & local.month & "," & local.day & ",'" & JSStringFormat(HTMLEditFormat(local.errorMsg)) & "');")/>
	</cffunction>

</cfcomponent>