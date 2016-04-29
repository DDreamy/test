package fvg
{
	import flash.net.*;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.FullScreenEvent;
	import flash.text.TextField;
	import fl.video.VideoEvent;
	import fl.video.VideoScaleMode;
	
	/******************************
	* DetailView class:
	* Extends MovieClip to create a detail view display
	* when a thumbnail is clicked in the video gallery.
	* -----------------------------
	* Developed by Dan Carr (dan@dancarrdesign.com) 
	* For Adobe Systems, Inc. - Adobe Developer Center
	* Last modified: November 24, 2008
	*/
	public class DetailView extends MovieClip
	{
		//***************************
		// Properties:
		
		public var labels:*;
		public var details:*;
		
		//***************************
		// Intialization:
		
		public function DetailView()
		{
			// Setup video
			display.fullScreenTakeOver = true;
			display.addEventListener(VideoEvent.READY, readyHandler);
			
			// Add listeners
			close.addEventListener(MouseEvent.CLICK, closeHandler);
			moreInfo.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		//***************************
		// Event handlers:
		
		// Video begins playing
		protected function readyHandler(event:VideoEvent):void
		{
			loadingBar.visible = false;
		}
			
		// Close button clicked
		protected function closeHandler(event:MouseEvent):void
		{
			// Dispatch CLOSE event
			dispatchEvent(new Event("close"));
		}
		
		// Link clicked
		protected function clickHandler(event:MouseEvent):void
		{
			// Call URL...
			var url:String = event.currentTarget.url;
			navigateToURL(new URLRequest(url), "_self");
		}
		
		//***************************
		// Public methods:
		
		public function setData(l, o):void
		{
			labels = l;
			details = o;
			
			// Set text fields
			title.htmlText = o.title;
			description.htmlText = o.description;
			
			// Set display state
			var path:String = o.@flv;
			if( path == display.source )
			{
				// Restart video...
				display.seek(0);
				display.play();
				loadingBar.visible = false;
			}
			else if( path != null )
			{
				// Progressive video uses a loadingbar
				// whereas streaming video does not...
				if( path.toLowerCase().indexOf("rtmp") == -1 && 
					path.toLowerCase().indexOf(".xml") == -1 )
				{
					// Set loading state
					loadingBar.visible = true;
				}else{
					loadingBar.visible = false;
				}
				// Load video
				display.source = o.@flv;
			}
			// Set text link
			moreInfo.setData(o.moreInfo, o.moreInfo.@url);
		}
		
		// Stop video
		public function reset():void
		{
			if( display.playing ){
				display.stop();
			}
			loadingBar.visible = true;
		}
	}
}