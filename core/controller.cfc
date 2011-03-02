<cfcomponent>
<cfscript>
	variables.settings = {};
	variables.plugins = {};
	variables.modules = {};
	variables.views = {};
	variables.layouts = {};

	function init(framework)
	{
		variables.framework = arguments.framework;
		return this;
	}

	function initPlugin(name)
	{
		if (not StructKeyExists(arguments, "key"))
		{
			arguments.key = arguments.name;
		}

		arguments.cache = true;

		getNewPlugin(argumentCollection = arguments);
	}

	function getNewPlugin(name)
	{
		var local = {};

		if (StructKeyExists(arguments, "path"))
		{
			local.path = arguments.path;
		}
		else
		{
			/*
				Check the following locations:
				    "/plugins/{environment}/plugin.cfc"
				    "/plugins/plugin.cfc"
				    "/alyx/plugins/plugin.cfc"
			*/

			if (Len(variables.framework.getEnvironment()) and FileExists(ExpandPath("/plugins/" & variables.framework.getEnvironment() & "/" & arguments.name & ".cfc")))
			{
				local.path = "/plugins." & variables.framework.getEnvironment();
			}
			else if (FileExists(ExpandPath("/plugins/" & arguments.name & ".cfc")))
			{
				local.path = "/plugins";
			}
			else
			{
				local.path = "/alyx.plugins";
			}
		}

		local.plugin = CreateObject("component", local.path & "." & arguments.name);

		if (StructKeyExists(arguments, "cache") and arguments.cache eq true)
		{
			variables.plugins[arguments.key] = local.plugin;
		}

		if (StructKeyExists(local.plugin, "init"))
		{
			if (StructKeyExists(arguments, "arguments"))
			{
				local.plugin.init(argumentCollection = arguments.arguments);
			}
			else
			{
				local.plugin.init();
			}
		}

		return local.plugin;
	}

	function getPlugin(name)
	{
		return variables.plugins[arguments.name];
	}

	function initModule(name)
	{
		var local = {};

		if (not StructKeyExists(arguments, "key"))
		{
			arguments.key = arguments.name;
		}

		if (StructKeyExists(arguments, "path"))
		{
			local.path = arguments.path;
		}
		else
		{
			/*
				Check the following locations:
				    "/modules/name/module.cfc"
				    "/alyx/modules/name/module.cfc"
			*/

			if (FileExists(ExpandPath("/modules/" & arguments.name & "/module.cfc")))
			{
				local.path = "/modules." & arguments.name;
			}
			else
			{
				local.path = "/alyx.modules." & arguments.name;
			}
		}

		variables.modules[arguments.key] = CreateObject("component", local.path & ".module");

		if (StructKeyExists(variables.modules[arguments.key], "init"))
		{
			if (StructKeyExists(arguments, "arguments"))
			{
				variables.modules[arguments.key].init(argumentCollection = arguments.arguments);
			}
			else
			{
				variables.modules[arguments.key].init();
			}
		}

		scanModuleDirectory("/alyx/modules/" & arguments.name & "/views", arguments.name, variables.views);
		scanModuleDirectory("/modules/" & arguments.name & "/views", arguments.name, variables.views);
		scanModuleDirectory("/alyx/modules/" & arguments.name & "/layouts", arguments.name, variables.layouts);
		scanModuleDirectory("/modules/" & arguments.name & "/layouts", arguments.name, variables.layouts);
	}

	function getModule(name)
	{
		return variables.modules[arguments.name];
	}

	function getModules()
	{
		return variables.modules;
	}

	function scanModuleDirectory(path, name, group)
	{
		var local = {};

		local.path = ExpandPath(arguments.path);

		if (DirectoryExists(local.path))
		{
			local.views = DirectoryList(local.path, true, "path", "*.cfm");
			local.numViews = ArrayLen(local.views);

			for (local.index = 1; local.index lte local.numViews; ++local.index)
			{
				local.file = local.views[local.index];
				local.file = Replace(local.file, local.path, "");
				local.file = ReReplace(local.file, "\.cfm$", "");
				local.file = Replace(local.file, "\", "/", "all");
				arguments.group[arguments.name & local.file] = arguments.path & local.file;
			}
		}
	}

	function getViewPath(view)
	{
		if (StructKeyExists(variables.views, arguments.view))
		{
			return variables.views[arguments.view];
		}
		return "/views/" & arguments.view;
	}

	function getLayoutPath(layout)
	{
		if (StructKeyExists(variables.layouts, arguments.layout))
		{
			return variables.layouts[arguments.layout];
		}
		return "/layouts/" & arguments.layout;
	}

	function getSettings()
	{
		return variables.settings;
	}

	function getContext()
	{
		return request.context;
	}

	function redirect()
	{
		variables.framework.redirect(argumentCollection = arguments);
	}

	function getAction()
	{
		return request.action;
	}

	function runAction(action)
	{
		variables.framework.runAction(argumentCollection = arguments);
	}

	function renderView()
	{
		variables.framework.renderView(argumentCollection = arguments);
	}

	function getEnvironment()
	{
		return variables.framework.getEnvironment();
	}

	function isDevEnvironment()
	{
		return variables.framework.isDevEnvironment();
	}

	function persist(keys)
	{
		variables.framework.storePersistentContext(arguments.keys);
	}

	function getService()
	{
		return variables.framework.getService(argumentCollection = arguments);
	}

	function logException(exception)
	{
		variables.framework.logException(argumentCollection = arguments);
	}

</cfscript>

	<cffunction name="getSetting" output="no">
		<cfargument name="name"/>
		<cfargument name="default" default=""/>
		<cfscript>

		if (StructKeyExists(variables.settings, arguments.name))
		{
			return variables.settings[arguments.name];
		}
		return arguments.default;

		</cfscript>
	</cffunction>

	<cffunction name="loadSettingsFile" output="no">
		<cfargument name="path"/>
		<cfset var settings = StructNew()/>
		<cfif FileExists(ExpandPath(arguments.path))>
			<cfinclude template="#path#"/>
		</cfif>
		<cfset StructAppend(variables.settings, settings)/>
	</cffunction>

	<cffunction name="renderContent" output="yes">
		<cfargument name="content" required="yes"/>
		<cfargument name="type" default="text/html"/>
		<cfcontent type="#arguments.type#" reset="yes"/>
		<cfoutput>#arguments.content#</cfoutput>
		<cfabort/>
	</cffunction>

</cfcomponent>