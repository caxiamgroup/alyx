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
			local.path = arguments.path & "." & arguments.name;
		}
		else
		{
			/*
				Check the following locations:
				    "/plugins/plugin.{environment}.cfc"
				    "/plugins/plugin.cfc"
				    "/alyx/plugins/plugin.cfc"
			*/

			local.environment = variables.framework.getEnvironment();

			if (Len(local.environment) && FileExists(ExpandPath("/plugins/" & arguments.name & "-" & local.environment & ".cfc")))
			{
				local.path = "/plugins." & arguments.name & "-" & local.environment;
			}
			else if (FileExists(ExpandPath("/plugins/" & arguments.name & ".cfc")))
			{
				local.path = "/plugins." & arguments.name;
			}
			else
			{
				local.path = "/alyx.plugins." & arguments.name;
			}
		}

		local.plugin = CreateObject("component", local.path);

		if (StructKeyExists(arguments, "cache") && arguments.cache == true)
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

		scanFrameworkDirectory("/alyx/modules/" & arguments.name & "/views", arguments.name, variables.views);
		scanFrameworkDirectory("/modules/" & arguments.name & "/views", arguments.name, variables.views);
		scanFrameworkDirectory("/alyx/modules/" & arguments.name & "/layouts", arguments.name, variables.layouts);
		scanFrameworkDirectory("/modules/" & arguments.name & "/layouts", arguments.name, variables.layouts);
	}

	function getModule(name)
	{
		return variables.modules[arguments.name];
	}

	function getModules()
	{
		return variables.modules;
	}

	function scanViewDirectory(path, name)
	{
		scanFrameworkDirectory(
			path = arguments.path,
			name = arguments.name,
			group = variables.views
		);
	}

	function scanLayoutDirectory(path, name)
	{
		scanFrameworkDirectory(
			path = arguments.path,
			name = arguments.name,
			group = variables.layouts
		);
	}

	function scanFrameworkDirectory(path, name, group)
	{
		var local = {};

		local.path = ExpandPath(arguments.path);

		if (DirectoryExists(local.path))
		{
			local.views = DirectoryList(local.path, true, "path", "*.cfm");
			local.numViews = ArrayLen(local.views);

			for (local.index = 1; local.index <= local.numViews; ++local.index)
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
		arguments.view = ReReplace(arguments.view, "^/", "");

		if (StructKeyExists(variables.views, arguments.view))
		{
			return variables.views[arguments.view];
		}
		return "/views/" & arguments.view;
	}

	function getLayoutPath(layout)
	{
		arguments.layout = ReReplace(arguments.layout, "^/", "");

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

	function runControllerMethod()
	{
		variables.framework.runControllerMethod(argumentCollection = arguments);
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