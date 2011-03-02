<cfcomponent name="DatasetBean" extends="dataset" output="no">

	<cffunction name="getCount" output="no">
		<cfreturn ArrayLen(variables.data)/>
	</cffunction>

	<cffunction name="getId" output="no">
		<cfargument name="row" default="#variables.currentRow#"/>
		<cfset var value = ""/>
		<cfinvoke component="#variables.data[arguments.row]#" method="get#variables.idField#" returnVariable="value"/>
		<cfreturn value/>
	</cffunction>

	<cffunction name="getLabel" output="no">
		<cfargument name="row" default="#variables.currentRow#"/>
		<cfset var value = ""/>
		<cfinvoke component="#variables.data[arguments.row]#" method="get#variables.labelField#" returnVariable="value"/>
		<cfreturn value/>
	</cffunction>

</cfcomponent>