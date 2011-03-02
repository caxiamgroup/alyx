<cfcomponent output="no" extends="text">

	<cffunction name="formatValue" access="private" output="false">
		<cfargument name="value" required="yes"/>
		<cfset arguments.value = ReReplace(arguments.value, "[^0-9.-]", "", "all")/>
		<cfif IsNumeric(arguments.value)>
			<cfset arguments.value = NumberFormat(arguments.value, ",0.00")/>
		</cfif>
		<cfreturn arguments.value/>
	</cffunction>

</cfcomponent>