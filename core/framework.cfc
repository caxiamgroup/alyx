<cfcomponent output="no"><cfsetting showdebugoutput="false"/><cfscript>

	this.sessionManagement = true;
	this.sessionTimeout = CreateTimeSpan(0, 4, 0, 0);

	this.mappings["/alyx"] = ReReplace(GetDirectoryFromPath(GetCurrentTemplatePath()), "(\\|/)core(\\|/){0,1}$", "");

	function _onApplicationStart()
	{
		checkFramework();
	}

	function _onSessionStart()
	{
		checkFramework();
		setupSession();
	}

	function _onMissingTemplate(targetPage)
	{
		onRequestStart(targetPage);
		onRequest(targetPage);
		onRequestEnd();
	}

	function _onRequestStart(targetPath)
	{
		checkFramework();

		initAction();

		if (not StructKeyExists(request, "context"))
		{
			request.context = {};
		}

		restorePersistentContext();

		if (IsDefined("url"))
		{
			StructAppend(request.context, url);
		}
		if (IsDefined("form"))
		{
			StructAppend(request.context, form);
		}

		request.action = url.action;

		setupRequest();

		request.controller = getController(request.action);

		if (not StructKeyExists(request, "layout"))
		{
			request.layout = variables.framework.defaultLayout;
		}

		if (not StructKeyExists(request, "view"))
		{
			request.view = request.action;
		}

		// Allow CFC requests through directly
		if (Right(targetPath, 4) eq ".cfc")
		{
			StructDelete(this, "onRequest");
			StructDelete(variables, "onRequest");
		}

		StructAppend(variables, application.controller.getPlugin("utils"));
	}

	function _onRequest(targetPath)
	{
		request.viewContexts = {};

		if (IsObject(request.controller))
		{
			runControllerMethod(request.controller, ListLast(request.action, "."));
		}
		WriteOutput(renderView());
	}

	function _onRequestEnd()
	{
	}

	function _setupApplication()
	{
	}

	function _setupSession()
	{
	}

	function _setupRequest()
	{
	}

	function _getEnvironment()
	{
		if (cgi.http_host contains ".localhost")
		{
			return "dev";
		}

		return "prod";
	}

	function _isDevEnvironment()
	{
		return ListFindNoCase("dev", getEnvironment()) gt 0;
	}

	function _getErrorEmailRecipients()
	{
		return "";
	}

	function renderView()
	{
		var content = "";

		if (not StructKeyExists(arguments, "view"))
		{
			arguments.view = request.view;
		}
		if (Len(arguments.view))
		{
			content = variables.view(ListChangeDelims(arguments.view, "/", "."), false);
		}
		if (not StructKeyExists(arguments, "layout"))
		{
			arguments.layout = request.layout;
		}
		if (Len(arguments.layout))
		{
			content = variables.layout(arguments.layout, content);
		}
		return content;
	}

	function getContext()
	{
		return request.context;
	}

	// PRIVATE ///////////////////////////////////////////////////////////////////////////////

	function initFrameworkSettings()
	{
		if (not StructKeyExists(variables, "framework"))
		{
			variables.framework = {};
		}
		if (not StructKeyExists(variables.framework, "restartPassword"))
		{
			variables.framework.restartPassword = "1";
		}
		if (not StructKeyExists(variables.framework, "cacheServices"))
		{
			variables.framework.cacheServices = isDevEnvironment() eq false;
		}
		if (not StructKeyExists(variables.framework, "cacheControllers"))
		{
			variables.framework.cacheControllers = isDevEnvironment() eq false;
		}
		if (not StructKeyExists(variables.framework, "defaultLayout"))
		{
			variables.framework.defaultLayout = "main";
		}
	}

	function initFramework()
	{
		var framework = {};

		framework.controllers = {};
		framework.services = {};

		application.framework = framework;

		request.frameworkInitialized = true;

		application.controller = CreateObject("component", "controller").init(this);

		loadFrameworkSettings();

		application.controller.loadSettingsFile("/config/settings.cfm");

		local.environment = getEnvironment();
		if (Len(local.environment))
		{
			application.controller.loadSettingsFile("/config/settings-" & local.environment & ".cfm");
		}

		application.controller.initPlugin(name = "snippets");
		application.controller.initPlugin(name = "forms");
		application.controller.initPlugin(name = "session");
		application.controller.initPlugin(name = "utils");

		setupApplication();

		application.initialized = Now();
	}

	function loadFrameworkSettings()
	{
		application.controller.loadSettingsFile("/alyx/config/settings.cfm");
	}

	function isRestartRequired()
	{
		// Using "IsDefined" to cover IsDefined("URL") condition

		return (not StructKeyExists(application, "initialized") or
			(
				IsDefined("url.restart") and
				url.restart eq variables.framework.restartPassword and
				not StructKeyExists(request, "frameworkInitialized")
			)
		);
	}

	function initAction()
	{
		/*
			Comments aren't the ideal place for documentation, but here it is, for now.

			<VirtualHost *:80>
				ServerName www.project.com
				DocumentRoot "C:/Development/projects/client/project/website"

				<Directory "C:/Development/projects/client/project/website">
					RewriteEngine On
					RewriteBase /
					RewriteCond %{REQUEST_FILENAME} !-f
					RewriteCond %{REQUEST_FILENAME} !-d
					RewriteCond %{REQUEST_URI} !/[^/]+\..+$
					RewriteRule ^(.+)$ /index.cfm?action=$1 [L,QSA]
				</Directory>
			</VirtualHost>

			http://www.project.com                    action=general.index
			http://www.project.com/login.cfm          action=general.login
			http://www.project.com/account/edit.cfm   action=account.edit
			http://www.project.com/account/edit       action=account.edit
			http://www.project.com/account/           action=account.index
			http://www.project.com/account            action=general.account
		*/

		if (StructKeyExists(url, "action"))
		{
			url.action = ReReplace(Replace(ReReplace(url.action, ".cfm$", ""), "/", ".", "all"), "\.$", ".index");
		}
		else
		{
			// Turn file request into implicit action
			url.action = ListChangeDelims(ListFirst(cgi.script_name, "."), ".", "/");
		}

		if (ListLen(url.action, ".") eq 1)
		{
			request.view = url.action;
			url.action = "general." & url.action;
		}
	}

	function runAction(action)
	{
		runControllerMethod(getController(arguments.action), ListLast(arguments.action, "."));
	}

	// Populate "super" scope
	if (! StructKeyExists(variables, "super"))
	{
		variables.super = {};
	}
	for (item in variables)
	{
		if (Left(item, 1) eq "_")
		{
			func = Mid(item, 2, Len(item));
			if (StructKeyExists(variables, func))
			{
				super[func] = variables[item];
			}
			else
			{
				variables[func] = variables[item];
			}
		}
	}

</cfscript><cfsilent>

	<cffunction name="checkFramework" access="private" output="no">
		<cfset initFrameworkSettings()/>

		<cfif isRestartRequired()>
			<cflock scope="application" type="exclusive" timeout="60">
				<cfif isRestartRequired()>
					<cfset initFramework()/>
				</cfif>
			</cflock>
		</cfif>
	</cffunction>

	<cffunction name="getService" output="no">
		<cfargument name="name" required="yes"/>

		<cfset var local = {}/>
		<cfset local.service = ""/>

		<cfif StructKeyExists(application.framework.services, arguments.name) and variables.framework.cacheServices>
			<cfset local.service = application.framework.services[arguments.name]/>
		<cfelse>
			<cflock name="framework.services.#arguments.name#" type="exclusive" timeout="20">
			<cfscript>
				if (StructKeyExists(application.framework.services, arguments.name) and variables.framework.cacheServices)
				{
					local.service = application.framework.services[arguments.name];
				}
				else
				{
					local.servicePath = "";
					local.path = ListChangeDelims(arguments.name, "/", ".");
					local.componentName = ListLast(local.path, "/");

					if (FileExists(ExpandPath("/models/" & local.path & "/" & local.componentName & "Service.cfc")))
					{
						local.servicePath = "/models." & arguments.name & "." & local.componentName & "Service";
					}
					else if (ListLen(arguments.name, ".") gt 1)
					{
						local.moduleName = ListFirst(arguments.name, ".");
						local.modules = application.controller.getModules();

						if (StructKeyExists(local.modules, local.moduleName))
						{
							if (FileExists(ExpandPath("/alyx/modules/" & local.moduleName & "/models/" & local.componentName & "/" & local.componentName & "Service.cfc")))
							{
								local.servicePath = "/alyx.modules." & local.moduleName & ".models." & local.componentName & "." & local.componentName & "Service";
							}
						}
					}

					if (Len(local.servicePath))
					{
						local.service = CreateObject("component", local.servicePath);
						if (StructKeyExists(local.service, "init"))
						{
							local.service.init(framework = this);
						}
						if (variables.framework.cacheServices)
						{
							application.framework.services[arguments.name] = local.service;
						}
					}
				}
			</cfscript>
			</cflock>
		</cfif>

		<cfreturn local.service/>
	</cffunction>

	<cffunction name="getController" output="no">
		<cfargument name="action" required="yes"/>

		<cfset var local = {}/>
		<cfset local.controller = ""/>
		<cfset local.name = ListDeleteAt(arguments.action, ListLen(arguments.action, "."), ".")/>

		<cfif StructKeyExists(application.framework.controllers, local.name) and variables.framework.cacheControllers>
			<cfset local.controller = application.framework.controllers[local.name]/>
		<cfelse>
			<cflock name="framework.controllers.#local.name#" type="exclusive" timeout="20">
			<cfscript>
				if (StructKeyExists(application.framework.controllers, local.name) and variables.framework.cacheControllers)
				{
					local.controller = application.framework.controllers[local.name];
				}
				else
				{
					local.controllerPath = "";
					local.path = ListChangeDelims(local.name, "/", ".");

					if (FileExists(ExpandPath("/controllers/" & local.path & ".cfc")))
					{
						local.controllerPath = "/controllers." & local.name;
					}
					else
					{
						for (local.module in application.controller.getModules())
						{
							if (FileExists(ExpandPath("/alyx/modules/" & local.module & "/controllers/" & local.path & ".cfc")))
							{
								local.controllerPath = "/alyx.modules." & local.module & ".controllers." & local.name;
								break;
							}
						}
					}

					if (Len(local.controllerPath))
					{
						local.controller = CreateObject("component", local.controllerPath);
						if (StructKeyExists(local.controller, "init"))
						{
							local.controller.init(framework = this);
						}
						if (variables.framework.cacheControllers)
						{
							application.framework.controllers[local.name] = local.controller;
						}
					}
				}
			</cfscript>
			</cflock>
		</cfif>

		<cfreturn local.controller/>
	</cffunction>

	<cffunction name="runControllerMethod" access="private" output="no">
		<cfargument name="controller"/>
		<cfargument name="method"/>
		<cfargument name="view" required="false"/>

		<cfset arguments.method = Replace(arguments.method, "-", "_", "all")/>

		<cfif StructKeyExists(arguments.controller, arguments.method) or StructKeyExists(arguments.controller, "onMissingMethod")>
			<cftry>
				<cfset request.viewContext = {}/>

				<cfif StructKeyExists(arguments.controller, "onBeforeControllerMethod")>
					<cfinvoke component="#arguments.controller#" method="onBeforeControllerMethod" rc="#request.context#" vc="#request.viewContext#" methodName="#arguments.method#"/>
				</cfif>

				<cfinvoke component="#arguments.controller#" method="#arguments.method#" rc="#request.context#" vc="#request.viewContext#"/>

				<cfif StructKeyExists(arguments.controller, "onAfterControllerMethod")>
					<cfinvoke component="#arguments.controller#" method="onAfterControllerMethod" rc="#request.context#" vc="#request.viewContext#" methodName="#arguments.method#"/>
				</cfif>

				<!--- Not using "default" attribute on cfargument so we can pick up on view changes via a call to setView in the controller method. --->
				<cfif not StructKeyExists(arguments, "view")>
					<cfset arguments.view = request.view/>
				</cfif>
				<cfset request.viewContexts[ListChangeDelims(arguments.view, "/", ".")] = request.viewContext/>

				<cfcatch type="any">
					<cfset request.failedCfcName = getMetadata(arguments.controller).fullname/>
					<cfset request.failedMethod = arguments.method/>
					<cfrethrow/>
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>

	<cffunction name="view" output="no">
		<cfargument name="path"/>
		<cfargument name="runController" default="false"/>

		<cfset var fw_out = ""/>
		<cfset var fw_action = ""/>
		<cfset var fw_controller = ""/>

		<cfset var rc = request.context/>
		<cfset var vc = {}/>

		<cfif arguments.runController>

			<cfset fw_action = ListChangeDelims(arguments.path, ".", "/")/>
			<cfset fw_action = ListChangeDelims(fw_action, "_", "-") />
			<cfif ListLen(fw_action, ".") eq 1>
				<cfset fw_action = "general." & fw_action/>
			</cfif>

			<cfset fw_controller = getController(fw_action)/>

			<cfif IsObject(fw_controller) and StructKeyExists(fw_controller, ListLast(fw_action, "."))>

				<cfset runControllerMethod(
					controller = fw_controller,
					method = ListLast(fw_action, "."),
					view = arguments.path
				)/>
			</cfif>
		</cfif>

		<cfif StructKeyExists(request.viewContexts, arguments.path)>
			<cfset vc = request.viewContexts[arguments.path]/>
			<cfset StructAppend(variables, vc)/>
		</cfif>

		<cfsavecontent variable="fw_out"><cfinclude template="#application.controller.getViewPath(arguments.path)#.cfm"/></cfsavecontent>

		<cfreturn fw_out/>
	</cffunction>

	<cffunction name="layout" output="no">
		<cfargument name="path"/>
		<cfargument name="body"/>

		<cfset var fw_out = ""/>
		<cfset var rc = request.context/>
		<cfset var local = {}/>

		<cfsavecontent variable="fw_out"><cfinclude template="#application.controller.getLayoutPath(arguments.path)#.cfm"/></cfsavecontent>

		<cfreturn fw_out/>
	</cffunction>

	<cffunction name="redirect" output="no">
		<cfargument name="action" required="yes"/>
		<cfargument name="persist" default=""/>
		<cfargument name="persistUrl" default=""/>

		<cfif Len(arguments.persist)>
			<cfset storePersistentContext(arguments.persist)>
		</cfif>

		<cfif Len(arguments.persistUrl)>
			<cfset arguments.persistUrl = "?" & arguments.persistUrl>
		</cfif>

		<cflocation url="#arguments.action#.cfm#arguments.persistUrl#" addtoken="no"/>
	</cffunction>

	<cffunction name="storePersistentContext" access="public" output="no">
		<cfargument name="keys" required="yes"/>
		<cfset var key = ""/>
		<cflock scope="session" type="exclusive" timeout="10">
			<cfif not StructKeyExists(session, "persistentContext")>
				<cfset session.persistentContext = {}/>
			</cfif>
			<cfloop list="#arguments.keys#" index="key">
				<cfif StructKeyExists(request.context, key)>
					<cfset session.persistentContext[key] = request.context[key]/>
				</cfif>
			</cfloop>
		</cflock>
	</cffunction>

	<cffunction name="restorePersistentContext" access="private" output="no">
		<cftry>
			<cflock scope="session" type="exclusive" timeout="10">
				<cfif StructKeyExists(session, "persistentContext")>
					<cfset StructAppend(request.context, session.persistentContext)/>
					<cfset StructDelete(session, "persistentContext")>
				</cfif>
			</cflock>
			<cfcatch type="any">
				<!--- Ignore --->
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="_onError" output="yes">
		<cfargument name="exception" default=""/>
		<cfargument name="event" default=""/>

		<cfset var local = StructNew()/>

		<cfif StructKeyExists(arguments.exception, "rootCause")>
			<cfset arguments.exception = arguments.exception.rootCause/>
		</cfif>

		<cfset logException(
			exception = arguments.exception,
			event = arguments.event
		)/>

		<cfif not isDevEnvironment()>
			<cftry>
				<cfif IsDefined("variables.framework.errorPage") and Len(variables.framework.errorPage)>
					<cfif not StructKeyExists(url, "errortoken")>
						<cflocation url="#variables.framework.errorPage#?errortoken=#session.cftoken#" addtoken="false"/>
					</cfif>
				<cfelseif FileExists(ExpandPath("/error.cfm"))>
					<cfinclude template="/error.cfm"/>
				<cfelse>
					<cfoutput>An error has occurred. Please try again in a few minutes.</cfoutput>
					<cfabort/>
				</cfif>

				<cfcatch>
					<!--- Ignore --->
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>

	<cffunction name="_logException" output="yes">
		<cfargument name="exception" required="yes"/>

		<cfset var local = StructNew()/>

		<cfset local.cgi = Duplicate(cgi)/>

		<!--- Hide sensitive fields --->
		<cfif StructKeyExists(local.cgi, "auth_password")>
			<cfset StructDelete(local.cgi, "auth_password")/>
		</cfif>
		<cfif StructKeyExists(local.cgi, "auth_user")>
			<cfset StructDelete(local.cgi, "auth_user")/>
		</cfif>

		<cfsavecontent variable="local.output">
		<cfoutput>
			<h1>Exception in <cfif StructKeyExists(arguments, "event")> #arguments.event#</cfif><cfif StructKeyExists(request, "action")> (#request.action#)</cfif></h1>
			<h2>#arguments.exception.message#</h2>
			<p>#arguments.exception.detail#</p>
			<cfdump var="#arguments.exception#"/>
			<cfdump var="#local.cgi#" label="CGI"/>
			<cfdump var="#form#" label="FORM"/>
			<cfif IsDefined("session.sessionID")>
			<cfdump var="#session.sessionID#" label="SESSIONID"/>
			</cfif>
		</cfoutput>
		</cfsavecontent>

		<cfif isDevEnvironment()>
			<cfoutput>#local.output#</cfoutput>
			<cfabort/>
		<cfelse>
			<cfif Len(getErrorEmailRecipients())>
				<cfmail from="errors@#cgi.server_name#" to="#getErrorEmailRecipients()#" subject="Website Error (#cgi.server_name#)" type="html">
					<cfoutput>#local.output#</cfoutput>
				</cfmail>
			</cfif>
		</cfif>
	</cffunction>

</cfsilent></cfcomponent>