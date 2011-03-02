<cfcomponent output="false">

	<cffunction name="uploadImage" access="private" output="no">
		<cfargument name="field" required="yes" />
		<cfargument name="path" required="yes" />

		<cfset var local = StructNew() />
		<cfset local.accept = "jpg,gif,png" />

		<cfsetting requesttimeout="300" />

		<cffile
			action="upload"
			filefield="#arguments.field#"
			destination="#arguments.path#"
			nameconflict="MAKEUNIQUE"
			result="local.file"
		/>

		<cfif local.file.fileWasSaved>
			<cfif not StructKeyExists(local.file, "serverFileExt") or
				not Len(local.file.serverFileExt) or
				not ListFindNoCase(local.accept, local.file.serverFileExt)
			>
				<cffile
					action="delete"
					file="#local.file.serverDirectory#/#local.file.serverFile#"
				/>

				<cfthrow type="ASSETS.BADFILETYPE" message="Invalid file type. Please make sure the image is one of the following types: #local.accept#." />
			</cfif>

			<cfset local.file.imageId = getUniqueId() />
			<cfset local.sourceFile = local.file.imageId & "_src." & local.file.serverFileExt/>

			<cffile
				action="rename"
				source="#local.file.serverDirectory#/#local.file.serverFile#"
				destination="#local.file.serverDirectory#/#local.sourceFile#"
			/>

			<cfset local.file.serverFile = local.sourceFile/>
		<cfelse>
			<cfthrow type="ASSETS.UPLOADFAILED" message="Upload of image failed." />
		</cfif>

		<cfset local.file.sourceFilePath = local.file.serverDirectory & "/" & local.file.serverFile/>

		<cfreturn local.file/>
	</cffunction>

	<cffunction name="resizeImage" access="private" output="no">
		<cfargument name="source" required="yes" />
		<cfargument name="destination" required="yes" />
		<cfargument name="width" required="yes" />
		<cfargument name="height" required="yes" />
		<cfargument name="fixed" default="false" />

		<cfset var local = StructNew() />

		<cfset local.image = ImageRead(arguments.source) />

		<cfif arguments.fixed>
			<cfif local.image.height gt local.image.width>
				<!--- Image is vertical --->
				<cfset ImageResize(local.image, arguments.width, '') />
				<cfset local.pos = (local.image.height / 2) - (arguments.height / 2) />
				<cfset ImageCrop(local.image, 0, local.pos, arguments.width, arguments.height) />
			<cfelseif local.image.width gt local.image.height>
				<!--- Image is horizontal --->
				<cfset ImageResize(local.image, '', arguments.height) />
				<cfset local.pos = (local.image.width / 2) - (arguments.width / 2) />
				<cfset ImageCrop(local.image, local.pos, 0, arguments.width, arguments.height) />
			<cfelse>
				<!--- Image is square --->
				<cfset ImageResize(local.image, arguments.width, arguments.height) />
			</cfif>
		<cfelse>
			<cfset ImageScaleToFit(local.image, arguments.width, arguments.height) />
		</cfif>

		<cfset ImageWrite(local.image, arguments.destination) />
	</cffunction>

	<cffunction name="renderImage" output="no">
		<cfargument name="path" required="yes" />
		<cfargument name="default" default="" />

		<cfset var local = StructNew() />
		<cfset local.imagePath = "" />

		<cfif Len(arguments.path) and FileExists(arguments.path)>
			<cfset local.imagePath = arguments.path/>
		</cfif>

		<cfif not Len(local.imagePath) and Len(arguments.default)>
			<cfset local.path = ExpandPath(arguments.default) />
			<cfif FileExists(local.path)>
				<cfset local.imagePath = local.path/>
			</cfif>
		</cfif>

		<cfif Len(local.imagePath)>
			<cfcontent file="#local.imagePath#" type="image/jpeg" />
		</cfif>
	</cffunction>

	<cffunction name="getUniqueId" access="private" output="no">
		<cfreturn Replace(CreateUuid(), "-", "", "all") />
	</cffunction>

	<cffunction name="ensurePathExists" access="public" output="false">
		<cfargument name="path" required="true" />

		<cfif not DirectoryExists(arguments.path)>
			<cfset CreateObject("java", "java.io.File").init(arguments.path).mkdirs() />
		</cfif>
	</cffunction>

</cfcomponent>