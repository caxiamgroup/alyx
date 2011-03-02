<cfcomponent output="no" extends="regexp">
	<cfset variables.regexp = "^([0-9a-fA-F]{3}){1,2}$"/>
	<cfset variables.error = "hexcolorbadformat"/>
</cfcomponent>