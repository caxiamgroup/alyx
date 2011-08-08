import java.util.ArrayList;

public class PagedArray<T> extends ArrayList<T> 
{ 
	private int recordCount = 0;
	private int pageSize = 0;
	private int pageIndex = 0;
	
	public PagedArray<T> init()
	{  
		return this;
	}

	public void setRecordCount(int recordCount)
	{
		this.recordCount = recordCount;
	}
	
	public int getRecordCount()
	{
		return this.recordCount;
	}
	
	public void setPageSize(int pageSize)
	{
		this.pageSize = pageSize;
	}
	
	public int getPageSize()
	{
		return this.pageSize;
	}
	
	public void setPageIndex(int pageIndex)
	{
		this.pageIndex = pageIndex;
	}
	
	public int getPageIndex()
	{
		return this.pageIndex;
	}
	
	public int getStartIndex() 
	{
		if(isEmpty())
		{
			return 0;
		}
		
		return this.pageSize * (this.pageIndex - 1) + 1;		
	}

	public int getEndIndex()
	{	
		if(isEmpty())
		{
			return 0;
		}
		
		return this.pageSize * (this.pageIndex - 1) + size();
	}

	public double getPageCount()
	{
		if(getRecordCount() > 0)
		{
			return Math.ceil((getRecordCount() / (double)getPageSize()));
		}
		
		return 0;
	}

}