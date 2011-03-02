<cfcomponent output="no" extends="text">

	<cffunction name="render" output="no">
		<cfargument name="field"         required="yes"/>
		<cfargument name="size"          default="10"/>
		<cfargument name="extra"         default=""/>
		<cfargument name="value"         default="#arguments.form.getFieldValue(arguments.field.name)#"/>
		<cfargument name="showCalendar"  default="true"/>

		<cfif arguments.showCalendar>
			<cfif arguments.extra contains "class=""">
				<cfset arguments.extra = Replace(arguments.extra, "class=""", "class=""dateinput ")/>
			<cfelse>
				<cfset arguments.extra &= " class=""dateinput"""/>
			</cfif>
		</cfif>

		<cfset arguments.extra &= " data-value=""" & DateFormat(arguments.value, "yyyy-mm-dd") & """"/>

		<cfreturn super.render(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="formatValue" access="private" output="false">
		<cfargument name="value" required="yes"/>
		<cfif IsDate(arguments.value)>
			<cfset arguments.value = DateFormat(arguments.value, "mm/dd/yyyy")/>
		</cfif>
		<cfreturn arguments.value/>
	</cffunction>

</cfcomponent>