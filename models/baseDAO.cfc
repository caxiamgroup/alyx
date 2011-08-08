<cfcomponent name="baseDAO" output="no" hint="Abstract base class for model DAOs">

	<cfset variables.RECORDSTATUS_DELETED = 0/>
	<cfset variables.RECORDSTATUS_ACTIVE  = 1/>
	<cfset variables.encryptionAlgorithm = "AES"/>
	<cfset variables.encryptionKey = application.controller.getSetting("encryptionKey")/>

	<cffunction name="queryRowToStruct" access="public" output="false" returntype="struct">
		<cfargument name="qry" type="query"   required="true"/>
		<cfargument name="row" type="numeric" default="1"/>

		<cfset var results = StructNew()/>
		<cfset var col = ""/>

		<cfloop list="#arguments.qry.columnList#" index="col">
			<cfset results[col] = arguments.qry[col][arguments.row]/>
		</cfloop>

		<cfreturn results/>
	</cffunction>

	<cffunction name="formatQuerySearchParam" access="private" output="false">
		<cfargument name="value" required="true"/>
		<cfif Find("%", arguments.value)>
			<cfreturn arguments.value/>
		<cfelseif Len(arguments.value) eq 1>
			<cfreturn arguments.value & "%"/>
		<cfelse>
			<cfreturn "%" & arguments.value & "%"/>
		</cfif>
	</cffunction>

	<cffunction name="getEncryptionKey" output="no">
		<cfargument name="salt" required="yes"/>
		<cfreturn ToBase64(BinaryDecode(Hash(variables.encryptionKey & arguments.salt), "HEX"))/>
	</cffunction>

	<cffunction name="encryptString" output="no">
		<cfargument name="value" required="yes"/>
		<cfargument name="key"   default="#variables.encryptionKey#"/>

		<cfset var results = ""/>

		<cfif Len(arguments.value)>
			<cfset results = Encrypt(arguments.value, arguments.key, variables.encryptionAlgorithm, "HEX")/>
		</cfif>

		<cfreturn results/>
	</cffunction>

	<cffunction name="decryptString" output="no">
		<cfargument name="value" required="yes"/>
		<cfargument name="key"   default="#variables.encryptionKey#"/>

		<cfset var results = ""/>

		<cfif Len(arguments.value)>
			<cfset results = Decrypt(arguments.value, arguments.key, variables.encryptionAlgorithm, "HEX")/>
		</cfif>

		<cfreturn results/>
	</cffunction>

	<cffunction name="getResultRecordCount" output="no">
		<cfquery name="local.resultRecordCount">
			SELECT FOUND_ROWS() AS `rows`;
		</cfquery>
		<cfreturn local.resultRecordCount.rows />
	</cffunction>
</cfcomponent>