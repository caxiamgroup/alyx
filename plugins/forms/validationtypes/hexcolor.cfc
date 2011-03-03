<cfcomponent output="no" extends="regexp">
<cfscript>

	variables.regexp = "^([0-9a-fA-F]{3}){1,2}$";
	variables.error = "hexcolorbadformat";

</cfscript>
</cfcomponent>