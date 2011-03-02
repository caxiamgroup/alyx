<cfcomponent>
<cfscript>

	variables.SOLR_VERSION = "2.2";

	function init(url = "")
	{
		setUrl(arguments.url);
		return this;
	}

	function setUrl(required url)
	{
		variables.url = arguments.url;
	}

	// http script doesn't work from within a thread
	/*
	function search(required params)
	{
		local.httpService = new http(
			url = "#variables.url#/select",
			method = "post"
		);
		local.httpService.addParam(
			type = "url",
			name = "version",
			value = variables.SOLR_VERSION
		);
		for (local.param in arguments.params)
		{
			local.httpService.addParam(
				type = "formField",
				name = LCase(ListFirst(param, "=")),
				value = ListRest(param, "=")
			);
		}

		return local.httpService.send().getPrefix().filecontent;
	}
	*/

	function add(required docs)
	{
		update("<add allowDups=""false"" overwritePending=""true"" overwriteCommitted=""true"">" & Trim(arguments.docs) & "</add>");
	}

	function deleteById(required id)
	{
		update("<delete fromPending=""true"" fromCommitted=""true""><id>" & Trim(arguments.id) & "</id></delete>");
	}

	function deleteByQuery(required query)
	{
		update("<delete fromPending=""true"" fromCommitted=""true""><query>" & Trim(arguments.query) & "</query></delete>");
	}

	function commit()
	{
		update("<commit waitFlush=""true"" waitSearcher=""true""/>");
	}

	function optimize()
	{
		update("<optimize waitFlush=""true"" waitSearcher=""true""/>");
	}

	// http script doesn't work from within a thread
	/*
	private function update(command)
	{
		local.httpService = new http(
			url = variables.url & "/update",
			method = "post",
			throwOnError = true
		);
		local.httpService.addParam(
			type = "xml",
			value = arguments.command
		);

		local.httpService.send();
	}
	*/

	function parseResults(xmlData, extractFacets = true)
	{
		local.results = {};

		local.search = XmlParse(arguments.xmldata);
		local.items = XmlSearch(local.search, "/response/result/doc");

		local.results.numFound = local.search.response.result.XmlAttributes.numFound;
		local.results.start = local.search.response.result.XmlAttributes.start + 1;

		// Extract the search results

		if (! ArrayIsEmpty(local.items))
		{
			local.columns = "";
			for (local.field in local.items[1].XmlChildren)
			{
				local.columns = ListAppend(local.columns, local.field.XmlAttributes.name);
			}
			local.data = QueryNew(local.columns);

			local.recordCount = ArrayLen(local.items);
			QueryAddRow(local.data, local.recordCount);
			for (local.row = 1; local.row <= local.recordCount; ++local.row)
			{
				local.item = local.items[local.row];
				for (local.field in local.item.XmlChildren)
				{
					QuerySetCell(local.data, local.field.XmlAttributes.name, local.field.XmlText, local.row);
				}
			}

			local.results.items = local.data;
		}
		else
		{
			local.results.items = QueryNew("");
		}

		if (arguments.extractFacets)
		{
			// Extract the facets

			local.facetData = XmlSearch(search, "/response/lst/lst[@name='facet_fields']/lst");

			local.data = {};

			for (local.facet in local.facetData)
			{
				local.name = local.facet.XmlAttributes.name;
				local.data[local.name] = [];
				for (local.spec in facet.XmlChildren)
				{
					if (Len(local.spec.XmlAttributes.name))
					{
						local.specdata = {};
						local.specdata.name = local.spec.XmlAttributes.name;
						local.specdata.count = local.spec.XmlText;
						ArrayAppend(local.data[name], local.specdata);
					}
				}
			}

			local.facetData = XmlSearch(local.search, "/response/lst/lst[@name='facet_queries']/int");

			if (ArrayLen(local.facetData))
			{
				local.data["custom_queries"] = [];
				for (local.spec in local.facetData)
				{
					if (Int(Val(spec.XmlText)) > 0)
					{
						local.specdata = {};
						local.specdata.name = ListFirst(local.spec.XmlAttributes.name, ":");
						local.specdata.count = local.spec.XmlText;
						ArrayAppend(data["custom_queries"], local.specdata);
					}
				}
			}

			local.results.facets = local.data;

			// Extract the facet queries (fq)

			local.facetData = XmlSearch(local.search, "/response/lst/lst/*[@name='fq']");
			local.data = [];

			if (ArrayLen(local.facetData))
			{
				local.facetData = local.facetData[1];
				if (local.facetData.XmlAttributes.name == "fq")
				{
					if (local.facetData.XmlName == "str")
					{
						ArrayAppend(local.data, local.facetData.XmlText);
					}
					else
					{
						for (local.child in local.facetData.XmlChildren)
						{
							ArrayAppend(local.data, local.child.XmlText);
						}
					}
				}
			}

			local.results.fq = local.data;
		}

		return local.results;
	}

	function formatSearchTerm(term)
	{
		local.termFormatted = Trim(arguments.term);

		local.termFormatted = Replace(local.termFormatted, "\", "\\", "all");
		local.termFormatted = Replace(local.termFormatted, ":", "\:", "all");
		local.termFormatted = Replace(local.termFormatted, """", "\""", "all");
		local.termFormatted = Replace(local.termFormatted, "(", "\(", "all");
		local.termFormatted = Replace(local.termFormatted, ")", "\)", "all");
		local.termFormatted = Replace(local.termFormatted, " or ",  " OR ",  "all");
		local.termFormatted = Replace(local.termFormatted, " and ", " AND ", "all");
		local.termFormatted = Replace(local.termFormatted, " not ", " NOT ", "all");

		return local.termFormatted;
	}

</cfscript>

	<cffunction name="search" output="false">
		<cfargument name="params"/>

		<cfhttp
			url = "#variables.url#/select"
			method = "post">
			<cfhttpparam
				type = "url"
				name = "version"
				value = "#variables.SOLR_VERSION#"/>
			<cfloop array="#arguments.params#" index="local.param">
				<cfhttpparam
					type = "formField"
					name = "#LCase(ListFirst(param, "="))#"
					value = "#ListRest(param, "=")#"/>
			</cfloop>
		</cfhttp>

		<cfreturn cfhttp.filecontent/>
	</cffunction>

	<cffunction name="update" output="false" access="private">
		<cfargument name="command"/>

		<cfhttp
			url = "#variables.url#/update"
			method = "post"
			throwOnError = "true">
			<cfhttpparam
				type = "xml"
				value = "#arguments.command#"/>
		</cfhttp>
	</cffunction>

</cfcomponent>