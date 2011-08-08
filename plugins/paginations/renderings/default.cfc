<cfcomponent name="default" >

	<cffunction name="init">
		<cfreturn THIS />
	</cffunction>

	<cffunction name="renderStartWrapper">
		<cfoutput>
			<ul class="pages">
		</cfoutput>
	</cffunction>

	<cffunction name="renderEndWrapper">
		<cfoutput>
			</ul>
		</cfoutput>
	</cffunction>

	<cffunction name="renderFirstPage">
		<cfoutput>
			<ul class="pagination"><li class="prev"><a href="?#ARGUMENTS.parsedUrlparams#">&laquo;</a></li>
		</cfoutput>
	</cffunction>

	<cffunction name="renderPreviousPage">
		<cfoutput>
			<li class="prev"><a href="?#ARGUMENTS.parsedUrlparams#">&lsaquo;</a></li>
		</cfoutput>
	</cffunction>

	<cffunction name="renderNexPage">
		<cfoutput>
			<li class="next"><a href="?#ARGUMENTS.parsedUrlparams#">&rsaquo;</a></li>
		</cfoutput>
	</cffunction>

	<cffunction name="renderLastPage">
		<cfoutput>
			<li class="next"><a href="?#ARGUMENTS.parsedUrlparams#">&raquo;</a></li></ul>
		</cfoutput>
	</cffunction>

	<cffunction name="renderPage">
		<cfoutput>
				<li>#link#</li>
		</cfoutput>
	</cffunction>

	<cffunction name="getSortOrderClass">
		<cfreturn ARGUMENTS.sortOrder />
	</cffunction>

</cfcomponent>