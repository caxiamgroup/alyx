<cfcomponent name="snippets" hint="Common snippets plugin" output="false">

	<cffunction name="init" access="public" returntype="snippets" output="false">
		<cfset loadSnippets()/>
		<cfreturn this/>
	</cffunction>

	<cffunction name="getSnippet" output="false" access="public" returntype="string" hint="Return text for a given snippet">
		<cfargument name="snippetId" required="yes"/>
		<cfargument name="pageId"    default="_common"/>

		<cfset var value = ""/>

		<cfif StructKeyExists(variables.snippets, arguments.pageId) and
			StructKeyExists(variables.snippets[arguments.pageId], arguments.snippetId)>
			<cfset value = variables.snippets[arguments.pageId][arguments.snippetId]/>
		</cfif>

		<cfreturn value/>
	</cffunction>

	<cffunction name="loadSnippets" output="false" access="private" returntype="string" hint="Loads common snippets">
		<cfset var data = ""/>
		<cfset var snippets = StructNew()/>

		<!--- Get Common/Global Snippets --->
		<cftry>
			<cfquery name="data" datasource="#application.controller.getSetting("staticDSN")#">
				SELECT * FROM snippets
			</cfquery>

			<cfloop query="data">
				<cfif not StructKeyExists(snippets, data.pageId)>
					<cfset snippets[data.pageId] = StructNew()/>
				</cfif>
				<cfset snippets[data.pageId][data.snippetId] = data.snippet/>
			</cfloop>
			<cfcatch type="database">
				<!--- Ignore error if snippets table doesn't exist --->
			</cfcatch>
		</cftry>

		<!--- Get Website Specific Snippets --->
		<cftry>
			<cfquery name="data" datasource="#application.controller.getSetting("DSN")#">
				SELECT * FROM snippets
			</cfquery>

			<cfloop query="data">
				<cfif not StructKeyExists(snippets, data.pageId)>
					<cfset snippets[data.pageId] = StructNew()/>
				</cfif>
				<cfset snippets[data.pageId][data.snippetId] = data.snippet/>
			</cfloop>
			<cfcatch type="database">
				<!--- Ignore error if snippets table doesn't exist --->
			</cfcatch>
		</cftry>

		<cfset variables.snippets = snippets/>
	</cffunction>

</cfcomponent>
