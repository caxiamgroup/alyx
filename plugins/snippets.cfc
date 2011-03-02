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
		<cfset var local = StructNew()/>

		<!--- Get snippets from framework --->

		<cfset local.file = ExpandPath("/alyx/config/snippets.json")/>
		<cffile action="read" file="#local.file#" variable="local.data"/>
		<cfset local.snippets = DeSerializeJson(local.data)/>

		<!--- Get snippets from website --->

		<cfset local.file = ExpandPath("/config/snippets.json")/>
		<cfif FileExists(local.file)>
			<cffile action="read" file="#local.file#" variable="local.data"/>
			<cfset local.siteSnippets = DeSerializeJson(local.data)/>

			<cfloop collection="#local.siteSnippets#" item="local.pageId">
				<cfif StructKeyExists(local.snippets, local.pageId)>
					<cfset StructAppend(local.snippets[local.pageId], local.siteSnippets[local.pageId])/>
				<cfelse>
					<cfset local.snippets[local.pageId] = local.siteSnippets[local.pageId]/>
				</cfif>
			</cfloop>
		</cfif>

		<cfset variables.snippets = local.snippets/>
	</cffunction>

</cfcomponent>
