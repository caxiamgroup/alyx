<cfcomponent>
<cfscript>
	variables.settings = {};
	variables.plugins = {};
	variables.modules = {};
	variables.views = {};
	variables.layouts = {};
	variables.models = {};
	variables.controllers = {};

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

		scanCFMDirectory("/alyx/modules/" & arguments.name & "/views", arguments.name, variables.views);
		scanCFMDirectory("/modules/" & arguments.name & "/views", arguments.name, variables.views);
		scanCFMDirectory("/alyx/modules/" & arguments.name & "/layouts", arguments.name, variables.layouts);
		scanCFMDirectory("/modules/" & arguments.name & "/layouts", arguments.name, variables.layouts);
	}

	function getModule(name)
	{
		return variables.modules[arguments.name];
	}

	function getModules()
	{
		return variables.modules;
	}

	function scanProjectDirectory(path)
	{
		var local = {};

		local.viewPath = arguments.path & "/views";
		local.controllerPath = arguments.path & "/controllers";
		local.modelsPath = arguments.path & "/models";
		local.layoutsPath = arguments.path & "/layouts";

		if(directoryExists(ExpandPath(local.viewPath)))
		{
			scanViewDirectory(local.viewPath);
		}

		if(directoryExists(ExpandPath(local.controllerPath)))
		{
			scanControllerDirectory(local.controllerPath);
		}

		if(directoryExists(ExpandPath(local.modelsPath)))
		{
			scanModelDirectory(local.modelsPath);
		}

		if(directoryExists(ExpandPath(local.layoutsPath)))
		{
			scanLayoutDirectory(local.layoutsPath);
		}
	}


	function scanViewDirectory(path, name = "")
	{
		scanCFMDirectory(
			path = arguments.path,
			name = arguments.name,
			group = variables.views
		);

	}

	function scanLayoutDirectory(path, name = "")
	{
		scanCFMDirectory(
			path = arguments.path,
			name = arguments.name,
			group = variables.layouts
		);
	}

	function scanModelDirectory(path)
	{
		scanCFCDirectory(
			path = arguments.path,
			group = variables.models
		);
	}

	function scanControllerDirectory(path)
	{
		scanCFCDirectory(
			path = arguments.path,
			group = variables.controllers
		);
	}

	function scanCFCDirectory(path, group)
	{
		var local = {};

		local.path = ExpandPath(arguments.path);

		if (DirectoryExists(local.path))
		{
			local.CFCs = DirectoryList(local.path, true, "path", "*.cfc");
			local.numCFCs = ArrayLen(local.CFCs);
			local.action = Replace(arguments.path, "/", ".", "all");
			local.action = Replace(local.action, ".", "/",  "one");
			for (local.index = 1; local.index <= local.numCFCs; ++local.index)
			{
				local.file = local.CFCs[local.index];
				local.file = Replace(local.file, local.path, "");
				local.file = ReReplace(local.file, "\.cfc$", "");
				local.file = Replace(local.file, "\", "/", "all");
				local.file = Replace(local.file, "/", ".", "all");
				local.key = Replace(local.file, ".", "",  "one");

				arguments.group[local.key] = local.action & local.file;
			}
		}
	}

	function scanCFMDirectory(path, name, group)
	{
		var local = {};

		local.path = ExpandPath(arguments.path);

		if (DirectoryExists(local.path))
		{
			local.CFMs = DirectoryList(local.path, true, "path", "*.cfm");
			local.numCFMs = ArrayLen(local.CFMs);

			for (local.index = 1; local.index <= local.numCFMs; ++local.index)
			{
				local.file = local.CFMs[local.index];
				local.file = Replace(local.file, local.path, "");
				local.file = ReReplace(local.file, "\.cfm$", "");
				local.file = Replace(local.file, "\", "/", "all");
				if (!Len(arguments.name))
				{
					local.key = Replace(local.file, "/", "", "one");
					arguments.group[local.key] = arguments.path & local.file;
				}
				else
				{
					arguments.group[arguments.name & local.file] = arguments.path & local.file;
				}
			}
		}
	}

	function getModelPath(model)
	{
		var local = {};

		local.serviceComponentPath = "";
		local.path = ListChangeDelims(arguments.model, "/", ".");
		local.action = ListChangeDelims(arguments.model, ".", "/");
		local.componentName = ListLast(local.path, "/");
		local.serviceAction = local.action & "." & local.componentName & "Service";

		if (FileExists(ExpandPath("/models/" & local.path & "/" & local.componentName & "Service.cfc")))
		{
			local.serviceComponentPath = "/models." & local.serviceAction;
		}
		else if (StructKeyExists(variables.models, local.serviceAction))
		{
			local.serviceComponentPath = variables.models[local.serviceAction];
		}
		else if (ListLen(local.action, ".") > 1)
		{
			local.moduleName = ListFirst(arguments.model, ".");
			local.modules = application.controller.getModules();

			if (StructKeyExists(local.modules, local.moduleName))
			{
				if (FileExists(ExpandPath("/alyx/modules/" & local.modules[local.moduleName].name & "/models/" & local.componentName & "/" & local.componentName & "Service.cfc")))
				{
					local.serviceComponentPath = "/alyx.modules." & local.modules[local.moduleName].name & ".models." & local.componentName & "." & local.componentName & "Service";
				}
			}
		}

		return local.serviceComponentPath;
	}

	function getControllerPath(controller)
	{
		var local = {};

		local.controllerPath = "";
		local.path = ListChangeDelims(arguments.controller, "/", ".");

		if (FileExists(ExpandPath("/controllers/" & local.path & ".cfc")))
		{
			local.controllerPath = "/controllers." & arguments.controller;
		}
		else if(StructKeyExists(variables.controllers, arguments.controller))
		{
			local.controllerPath = variables.controllers[arguments.controller];
		}
		else
		{
			for (local.module in application.controller.getModules())
			{
				if (FileExists(ExpandPath("/alyx/modules/" & local.module & "/controllers/" & local.path & ".cfc")))
				{
					local.controllerPath = "/alyx.modules." & local.module & ".controllers." & arguments.controller;
					break;
				}
			}
		}

		return local.controllerPath;
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