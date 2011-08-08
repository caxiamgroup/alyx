<cfcomponent name="forum" >

	<cffunction name="init">
		<cfreturn THIS />
	</cffunction>

	<cffunction name="renderStartWrapper">
		<cfoutput>
			[ Page #arguments.serviceArguments.pageIndex# of #arguments.serviceArguments.pageCount# ]
		</cfoutput>
	</cffunction>

	<cffunction name="renderFirstPage">
		<cfoutput>
			<a href="?#ARGUMENTS.parsedUrlparams#"><span class="first" title="First">&nbsp;</span></a>
		</cfoutput>
	</cffunction>

	<cffunction name="renderPreviousPage">
		<cfoutput>
			<a href="?#ARGUMENTS.parsedUrlparams#"><span class="previous" title="Previous">&nbsp;</span></a>
		</cfoutput>
	</cffunction>

	<cffunction name="renderNexPage">
		<cfoutput>
			<a href="?#ARGUMENTS.parsedUrlparams#"><span class="next" title="Next">&nbsp;</span></a>
		</cfoutput>
	</cffunction>

	<cffunction name="renderLastPage">
		<cfoutput>
			<a href="?#ARGUMENTS.parsedUrlparams#"><span class="last" title="Last">&nbsp;</span></a>
		</cfoutput>
	</cffunction>

	<cffunction name="renderPage">
		<cfoutput>
				#link#
		</cfoutput>
	</cffunction>

	<cffunction name="getSortOrderClass">
		<cfreturn ARGUMENTS.sortOrder />
	</cffunction>

</cfcomponent>