<cfcomponent output="false">
<cfscript>

	function init(framework)
	{
		variables.framework = arguments.framework;

		StructAppend(variables, application.controller.getPlugin("utils"));

		return this;
	}

	function restart()
	{
		setNoRender();
	}

	function saveSearchParams(key, form)
	{
		application.controller.getPlugin("session").setVar("search-" & arguments.key, arguments.form.serialize());
	}

	function restoreSearchParams(key)
	{
		arguments.key = "search-" & arguments.key;

		if (StructKeyExists(arguments, "reset") && arguments.reset == true)
		{
			application.controller.getPlugin("session").deleteVar(arguments.key);
		}
		else if (application.controller.getPlugin("session").exists(arguments.key))
		{
			arguments.form.deserialize(application.controller.getPlugin("session").getVar(arguments.key));
			arguments.form.setSubmitted();
		}
	}

	function getSearchParams(key)
	{
		return application.controller.getPlugin("session").getVar(arguments.key);
	}

	function getContext()
	{
		return request.context;
	}

	function getSetting(name)
	{
		return application.controller.getSetting(argumentCollection = arguments);
	}

	function getForm(name)
	{
		return application.controller.getPlugin("forms").getForm(arguments.name);
	}

	function getSnippet(snippetId)
	{
		return application.controller.getPlugin("snippets").getSnippet(argumentCollection = arguments);
	}

	function getPlugin(name)
	{
		return application.controller.getPlugin(arguments.name);
	}

	function getLayout()
	{
		return request.layout;
	}

	function setLayout(name)
	{
		request.layout = arguments.name;
	}

	function getView()
	{
		return request.view;
	}

	function setView(name)
	{
		request.view = arguments.name;
	}

	function renderJson()
	{
		request.rendering = "json";
	}
	function renderXML()
	{
		request.rendering = "xml";
	}
	function setNoLayout()
	{
		setLayout("");
	}
	function setNoRender()
	{
		setLayout("");
		setView("");
	}

	function runControllerMethod()
	{
		return application.controller.runControllerMethod(argumentCollection = arguments);
	}

	function redirect(action)
	{
		return application.controller.redirect(argumentCollection = arguments);
	}

	function persist(keys)
	{
		return application.controller.persist(argumentCollection = arguments);
	}

	function getService(name)
	{
		return application.controller.getService(arguments.name);
	}

	function logException(exception)
	{
		application.controller.logException(argumentCollection = arguments);
	}

	function preCalculatePaging(pageSize, currentPage)
	{
		var paging = StructNew();

		paging.startRow = (Max(Int(Val(arguments.currentPage)), 1) - 1) * arguments.pageSize + 1;
		paging.endRow = paging.startRow + arguments.pageSize - 1;

		return paging;
	}

	function calculatePaging(recordCount, pageSize, pageRange, currentPage)
	{
		var paging = Duplicate(arguments);
		var tempPageRange = Max(paging.pageRange - 1, 1);

		if (paging.recordCount > 0)
		{
			paging.numPages = Ceiling(paging.recordCount / paging.pageSize);

			paging.currentPage = Int(Val(paging.currentPage));
			paging.currentPage = Min(paging.currentPage, paging.numPages);
			paging.currentPage = Max(paging.currentPage, 1);

			paging.startPage = Fix(paging.currentPage - (tempPageRange / 2));
			paging.startPage = Max(paging.startPage, 1);

			paging.endPage = paging.startPage + tempPageRange;
			if (paging.endPage > paging.numPages)
			{
				paging.endPage = paging.numPages;
				paging.startPage = paging.endPage - tempPageRange;
				paging.startPage = Max(paging.startPage, 1);
			}

			if (paging.currentPage > 1)
			{
				paging.prevPage = paging.currentPage - 1;
			}
			else
			{
				paging.prevPage = "";
			}

			if (paging.currentPage < paging.numPages)
			{
				paging.nextPage = paging.currentPage + 1;
			}
			else
			{
				paging.nextPage = "";
			}

			paging.startRow = (paging.currentPage - 1) * paging.pageSize + 1;
			paging.endRow = paging.startRow + paging.pageSize - 1;
			paging.endRow = Min(paging.endRow, paging.recordCount);
		}
		else
		{
			paging.numPages = 0;
			paging.currentPage = 0;
		}

		return paging;
	}

</cfscript>
</cfcomponent>
