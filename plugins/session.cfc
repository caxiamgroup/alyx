<cfcomponent>

	<cffunction name="init" output="no">
		<cfargument name="storage_key" default="framework_storage"/>

		<cfset variables.storage_key_scoped = arguments.storage_key & "_S"/>
		<cfset variables.storage_key_unscoped = arguments.storage_key & "_U"/>

	</cffunction>

	<cffunction name="exists" output="no">
		<cfargument name="name" required="yes"/>
		<cfargument name="scope" default=""/>

		<cfset var exists = false/>

		<cflock scope="session" type="readonly" timeout="10">
			<cfscript>

			if (Len(arguments.scope))
			{
				if (StructKeyExists(session, variables.storage_key_scoped)
					and StructKeyExists(session[variables.storage_key_scoped], arguments.scope)
					and StructKeyExists(session[variables.storage_key_scoped][arguments.scope], arguments.name))
				{
					exists = true;
				}
			}
			else if (StructKeyExists(session, variables.storage_key_unscoped)
				and StructKeyExists(session[variables.storage_key_unscoped], arguments.name))
			{
				exists = true;
			}

			</cfscript>
		</cflock>

		<cfreturn exists/>
	</cffunction>

	<cffunction name="setVar" output="no">
		<cfargument name="name" required="yes"/>
		<cfargument name="value" default=""/>
		<cfargument name="scope" default=""/>

		<cflock scope="session" type="exclusive" timeout="10">
			<cfscript>

			if (Len(arguments.scope))
			{
				if (not StructKeyExists(session, variables.storage_key_scoped))
				{
					session[variables.storage_key_scoped] = {};
				}

				if (not StructKeyExists(session[variables.storage_key_scoped], arguments.scope))
				{
					session[variables.storage_key_scoped][arguments.scope] = {};
				}

				session[variables.storage_key_scoped][arguments.scope][arguments.name] = arguments.value;
			}
			else
			{
				if (not StructKeyExists(session, variables.storage_key_unscoped))
				{
					session[variables.storage_key_unscoped] = {};
				}

				session[variables.storage_key_unscoped][arguments.name] = arguments.value;
			}

			</cfscript>
		</cflock>
	</cffunction>

	<cffunction name="getVar" output="no">
		<cfargument name="name" required="yes"/>
		<cfargument name="default" default=""/>
		<cfargument name="scope" default=""/>

		<cfset var value = arguments.default/>

		<cflock scope="session" type="readonly" timeout="10">
			<cfscript>

			if (Len(arguments.scope))
			{
				if (StructKeyExists(session, variables.storage_key_scoped)
					and StructKeyExists(session[variables.storage_key_scoped], arguments.scope)
					and StructKeyExists(session[variables.storage_key_scoped][arguments.scope], arguments.name))
				{
					value = session[variables.storage_key_scoped][arguments.scope][arguments.name];
				}
			}
			else if (StructKeyExists(session, variables.storage_key_unscoped)
				and StructKeyExists(session[variables.storage_key_unscoped], arguments.name))
			{
				value = session[variables.storage_key_unscoped][arguments.name];
			}

			</cfscript>
		</cflock>

		<cfreturn value/>
	</cffunction>

	<cffunction name="deleteVar" output="no">
		<cfargument name="name" required="yes"/>
		<cfargument name="scope" default=""/>

		<cflock scope="session" type="exclusive" timeout="10">
			<cfscript>

			if (Len(arguments.scope))
			{
				if (StructKeyExists(session, variables.storage_key_scoped)
					and StructKeyExists(session[variables.storage_key_scoped], arguments.scope)
					and StructKeyExists(session[variables.storage_key_scoped][arguments.scope], arguments.name))
				{
					StructDelete(session[variables.storage_key_scoped][arguments.scope], arguments.name);
				}
			}
			else if (StructKeyExists(session, variables.storage_key_unscoped)
				and StructKeyExists(session[variables.storage_key_unscoped], arguments.name))
			{
				StructDelete(session[variables.storage_key_unscoped], arguments.name);
			}

			</cfscript>
		</cflock>
	</cffunction>

	<cffunction name="deleteScope" output="no">
		<cfargument name="name" required="yes"/>
		<cfargument name="scope" required="yes"/>

		<cflock scope="session" type="exclusive" timeout="10">
			<cfscript>

			if (StructKeyExists(session, variables.storage_key_scoped)
				and StructKeyExists(session[variables.storage_key_scoped], arguments.scope))
			{
				StructDelete(session[variables.storage_key_scoped], arguments.scope);
			}

			</cfscript>
		</cflock>
	</cffunction>

	<cffunction name="clearAll" output="no">
		<cflock scope="session" type="exclusive" timeout="10">
			<cfset StructDelete(session, variables.storage_key_scoped)/>
			<cfset StructDelete(session, variables.storage_key_unscoped)/>
		</cflock>
	</cffunction>

</cfcomponent>