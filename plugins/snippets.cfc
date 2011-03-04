<cfcomponent name="snippets" hint="Common snippets plugin" output="false">
<cfscript>

	function init()
	{
		loadSnippets();
		return this;
	}

	function getSnippet(required snippetId, pageId = "common", defaultValue = "")
	{
		if (StructKeyExists(variables.snippets, arguments.pageId) &&
			StructKeyExists(variables.snippets[arguments.pageId], arguments.snippetId))
		{
			return variables.snippets[arguments.pageId][arguments.snippetId];
		}

		return arguments.defaultValue;
	}

	function getSnippets(required pageId)
	{
		return variables.snippets[arguments.pageId];
	}

	function loadSnippets()
	{
		var local = {};

		// Get snippets from framework

		local.file = ExpandPath("/alyx/config/snippets.json");
		local.data = FileRead(local.file);
		local.snippets = DeSerializeJson(local.data);

		// Get snippets from website

		local.file = ExpandPath("/config/snippets.json");
		if (FileExists(local.file))
		{
			local.data = FileRead(local.file);
			local.siteSnippets = DeSerializeJson(local.data);

			for (local.pageId in local.siteSnippets)
			{
				if (StructKeyExists(local.snippets, local.pageId))
				{
					StructAppend(local.snippets[local.pageId], local.siteSnippets[local.pageId]);
				}
				else
				{
					local.snippets[local.pageId] = local.siteSnippets[local.pageId];
				}
			}
		}

		variables.snippets = local.snippets;
	}

</cfscript>
</cfcomponent>