component name="pagination" accessors="true"
{
	public function init(
		recordCount = 0,
		pageSize = 0,
		pageCount = 0,
		pageIndex = 0,
		rc = StructNew(),
		serviceArguments = StructNew(),
		isFilterApplied = false,
		startIndex = 0,
		endIndex = 0,
		rendering = StructNew()
	)
	{
		VARIABLES.recordCount          = ARGUMENTS.recordCount;
		VARIABLES.pageSize             = ARGUMENTS.pageSize;
		VARIABLES.pageCount            = ARGUMENTS.pageCount;
		VARIABLES.pageIndex            = ARGUMENTS.pageIndex;
		VARIABLES.startPage            = Max((Min(VARIABLES.pageIndex, VARIABLES.pageCount) - (ARGUMENTS.serviceArguments.pageRange /2 )), 1);
		VARIABLES.endPage              = Min(VARIABLES.startPage + ARGUMENTS.serviceArguments.pageRange, VARIABLES.pageCount + 1);
		VARIABLES.startPage            = Max(Min(VARIABLES.startPage, VARIABLES.pageCount - ARGUMENTS.serviceArguments.pageRange), 1);
		VARIABLES.rc                   = ARGUMENTS.rc;
		VARIABLES.isFilterApplied      = ARGUMENTS.isFilterApplied;
		VARIABLES.startPage            = VARIABLES.startPage ;
		VARIABLES.startIndex           = ARGUMENTS.startIndex;
		VARIABLES.endIndex             = ARGUMENTS.endIndex;
		VARIABLES.serviceArguments     = ARGUMENTS.serviceArguments;
		VARIABLES.rendering = ARGUMENTS.rendering;

		if(StructKeyExists(VARIABLES.serviceArguments, "orderBy"))
		{
			VARIABLES.serviceArguments.orderBy = ListChangeDelims(VARIABLES.serviceArguments.orderBy, ",", " ");
		}

		return THIS;
	}

	public function isFilterApplied()
	{
		return VARIABLES.isFilterApplied;
	}

	public function parseURLparams(required urlParams)
	{
		local.parsedUrlParams = '';
		local.invalidParams = 'endIndex,startIndex,isfilterapplied,pagerange,pagecount';

		for(local.param in ARGUMENTS.urlParams)
		{
			if(LEN(TRIM(ARGUMENTS.urlParams[local.param])) AND ListFindNocase(local.invalidParams, TRIM(local.param)) EQ 0)
			{
				local.currentParam    = lCase(local.param) & '=' & ARGUMENTS.urlParams[local.param];
				local.parsedUrlParams = ListAppend(local.parsedUrlParams, local.currentParam, "&");
			}
		}

		return local.parsedUrlParams;
	}

	public function setDefaultOrderBy(localUrlParams, startDesc)
	{
		if(StructKeyExists(ARGUMENTS.localUrlParams,'orderBy') AND ListLen(ARGUMENTS.localUrlParams.orderBy) EQ 1)
		{
			local.direction = (!ARGUMENTS.startDesc)?",asc":",desc";
			ARGUMENTS.localUrlParams.orderBy =  ListGetAt(ARGUMENTS.localUrlParams.orderBy, 1) & local.direction;
		}
	}

	public function hasOrderBy(urlParams)
	{
		return 	StructKeyExists(ARGUMENTS.urlParams,"orderBy") AND LEN(ARGUMENTS.urlParams.orderBY);
	}

	public function flipOrderBy(localUrlParams, overrideVariables)
	{
		var local = StructNew();

		if(this.hasOrderBy(ARGUMENTS.localUrlParams) AND this.hasOrderBy(ARGUMENTS.overrideVariables) AND this.hasOrderBy(VARIABLES.serviceArguments))
		{
			local.orderBy = ListToArray(ARGUMENTS.localUrlParams.orderBy);
			local.currentOrderBy = ListToArray(VARIABLES.serviceArguments.orderBy);

			if(ARGUMENTS.overrideVariables.orderBy EQ  local.orderBy[1] AND local.currentOrderBy[1] EQ local.orderBy[1])
			{
				if(ArrayLen(local.currentOrderBy) EQ 2 AND local.currentOrderBy[2] EQ "desc")
				{
					local.orderBy[2] = "asc";
				}
				else if(ArrayLen(local.currentOrderBy) EQ 2 AND local.currentOrderBy[2] EQ "asc")
				{
					local.orderBy[2] = "desc";
				}
			}
			ARGUMENTS.localUrlParams.orderBy = ArrayToList(local.orderBy);
		}
	}

	public function getLink(
		linkText = VARIABLES.serviceArguments['pageIndex'],
		overrideVariables = StructNew(),
		styles = "",
		extra = "",
		startDesc = false
	)
	{
		var local = StructNew();

		local.urlParams = Duplicate(VARIABLES.serviceArguments);
		StructAppend(local.urlparams, ARGUMENTS.overrideVariables);
		param name = "local.serviceArguments.pageIndex" default = VARIABLES.pageIndex;

		if(local.urlParams['pageIndex'] EQ VARIABLES.pageIndex)
		{
			ARGUMENTS.extra &= ' class="current" ';
		}

		setDefaultOrderBy(local.urlParams, ARGUMENTS.startDesc);
		flipOrderBy(local.urlParams, overrideVariables);

		local.parsedUrlParams  = parseURLparams(local.urlParams);

		return '<a style="' & ARGUMENTS.styles & '" href="?' & local.parsedUrlParams & '" ' & ARGUMENTS.extra & '>' & ARGUMENTS.linkText &'</a>';
		/**/
	}

	public function renderPagination()
	{
		if(VARIABLES.endPage GT 1)
		{
			local.prevPage = VARIABLES.pageIndex;
			local.prevPage = Max(--local.prevPage,1);

			local.nextPage  = VARIABLES.pageIndex;
			local.nextPage = Min(++local.nextPage, VARIABLES.pageCount);
			VARIABLES.serviceArguments.pageCount = VARIABLES.pageCount;
			VARIABLES.serviceArguments.startIndex  = VARIABLES.startIndex;
			VARIABLES.serviceArguments.endIndex    = VARIABLES.endIndex;
			VARIABLES.serviceArguments.recordCount = VARIABLES.recordCount;

			if(variables.pageCount > 1)
			{
				if(StructKeyExists(VARIABLES.rendering, "renderStartWrapper"))
				{
					VARIABLES.rendering.renderStartWrapper(parsedUrlparams = parseURLparams(VARIABLES.serviceArguments), serviceArguments = VARIABLES.serviceArguments);
				}

				if(StructKeyExists(VARIABLES.rendering, "renderFirstPage") AND VARIABLES.startPage GT 1)
				{
					VARIABLES.serviceArguments['pageIndex'] = 1;
					VARIABLES.rendering.renderFirstPage(parsedUrlparams = parseURLparams(VARIABLES.serviceArguments), serviceArguments = VARIABLES.serviceArguments);
				}

				if(StructKeyExists(VARIABLES.rendering, "renderPreviousPage") AND VARIABLES.pageIndex NEQ 1)
				{
					VARIABLES.serviceArguments['pageIndex'] = local.prevPage;
					VARIABLES.rendering.renderPreviousPage(parsedUrlparams = parseURLparams(VARIABLES.serviceArguments), serviceArguments = VARIABLES.serviceArguments);
				}

				if(VARIABLES.pageCount GT 1)
				{
					for(local.pageIndex = VARIABLES.startPage ; local.pageIndex < VARIABLES.endPage; ++local.pageIndex)
					{
						VARIABLES.serviceArguments['pageIndex'] = local.pageIndex;
						VARIABLES.rendering.renderPage(link = getLink(local.pageIndex));
					}
				}

				if(StructKeyExists(VARIABLES.rendering, "renderNexPage") AND VARIABLES.pageIndex LT VARIABLES.pageCount )
				{
					VARIABLES.serviceArguments['pageIndex'] = local.nextPage;
					VARIABLES.rendering.renderNexPage(parsedUrlparams = parseURLparams(VARIABLES.serviceArguments), serviceArguments = VARIABLES.serviceArguments);
				}

				if(StructKeyExists(VARIABLES.rendering, "renderLastPage") AND VARIABLES.endPage NEQ VARIABLES.pageCount + 1)
				{
					VARIABLES.serviceArguments['pageIndex'] = VARIABLES.pageCount;
					VARIABLES.rendering.renderLastPage(parsedUrlparams = parseURLparams(VARIABLES.serviceArguments), serviceArguments = VARIABLES.serviceArguments);
				}

				if(StructKeyExists(VARIABLES.rendering, "renderEndWrapper"))
				{
					VARIABLES.rendering.renderEndWrapper(parsedUrlparams = parseURLparams(VARIABLES.serviceArguments), serviceArguments = VARIABLES.serviceArguments);
				}
			}
		}

		VARIABLES.serviceArguments['pageIndex'] = VARIABLES.pageIndex;
		return " ";
	}

	public function renderRecordPerPage(intervals = APPLICATION.controller.getSetting("PAGINATION_DEFAULT_PAGE_INTERVALS", "10,25,50,100"))
	{
		local.intervals = ListToArray(ARGUMENTS.intervals);
		local.intervalLinks = [];

		for(local.interval in local.intervals)
		{
			VARIABLES.serviceArguments['pageSize'] = local.interval;
			ArrayAppend(local.intervalLinks, getLink(local.interval));
		}
		VARIABLES.serviceArguments['pageSize'] = VARIABLES.pageSize;
		VARIABLES.rendering.renderRecordPerPage(intervalLinks = local.intervalLinks, pageSize = VARIABLES.pageSize);
	}

	public function getSortOrderClass(filterName)
	{
		local.sortOrder = '';
		if(StructKeyExists(VARIABLES.serviceArguments, 'orderBy') AND listFindNocase(VARIABLES.serviceArguments.orderBy, ARGUMENTS.filterName))
		{
			local.sortOrder = 'asc';

			if(listFindNocase(VARIABLES.serviceArguments.orderBy, 'desc'))
			{
				local.sortOrder = 'desc';
			}

			if(StructKeyExists(VARIABLES.rendering, "getSortOrderClass"))
			{
				local.sortOrder = VARIABLES.rendering.getSortOrderClass(sortOrder = local.sortOrder);
			}
		}

		return local.sortOrder;
	}

}