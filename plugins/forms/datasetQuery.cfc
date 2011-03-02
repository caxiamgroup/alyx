<cfcomponent name="DatasetQuery" extends="dataset" output="no">

	<cffunction name="getCount" output="no">
		<cfreturn variables.data.recordcount/>
	</cffunction>

	<cffunction name="getId" output="no">
		<cfargument name="row" default="#variables.currentRow#"/>
		<cfreturn variables.data[variables.idField][arguments.row]/>
	</cffunction>

	<cffunction name="getLabel" output="no">
		<cfargument name="row" default="#variables.currentRow#"/>
		<cfreturn variables.data[variables.labelField][arguments.row]/>
	</cffunction>

	<cffunction name="getGroupId" output="no">
		<cfargument name="row" default="#variables.currentRow#"/>
		<cfreturn variables.data[variables.groupIdField][arguments.row]/>
	</cffunction>

	<cffunction name="getGroupLabel" output="no">
		<cfargument name="row" default="#variables.currentRow#"/>
		<cfreturn variables.data[variables.groupLabelField][arguments.row]/>
	</cffunction>

</cfcomponent>