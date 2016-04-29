package fvg
{
	import flash.display.*;
	import flash.events.*;
	import fl.video.*;
	
	/******************************
	* VideoThumbnail class:
	* Extends MovieClip to act as a button for thumbnail
	* video selection in the Flash Video Gallery interface.
	* -----------------------------
	* Developed by Dan Carr (dan@dancarrdesign.com) 
	* For Adobe Systems, Inc. - Adobe Developer Center
	* Last modified: November 24, 2008
	*/
	public class VideoThumbnail extends MovieClip
	{
		//***************************
		// Properties:
		
		public var data					:Object;
		public var index				:Number;
		
		//***************************
		// Intialization:
		
		public function VideoThumbnail()
		{
			// Construct!
			buttonMode = true;
			useHandCursor = true;
			outline.visible = false;
			hilight_mc.visible = false;
			display.fullScreenTakeOver = false;
		}
		
		//***************************
		// Handle events:
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			if( enabled )
			{
				// Adjust state
				outline.visible = true;
				scaleX = scaleY = 1.5;
				
				// Play video
				playVideo();
			}
		}
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			if( enabled )
			{
				// Adjust state
				outline.visible = false;
				scaleX = scaleY = 1;
					
				// Pause video
				pauseVideo();
			}
		}
		
		protected function readyHandler(event:VideoEvent):void
		{
			// Signal that we're ready
			dispatchEvent(event.clone());
		}
		
		protected function completeHandler(event:VideoEvent):void
		{
			// Check to see if we're streaming,
			// in that case we won't loop and
			// risk a player crash while overlapping
			// with other video thumbnails...
			var path:String = data.@preview.toLowerCase();
			if( path.indexOf("rtmp") == -1 && 
				path.indexOf(".xml") == -1 )
			{
				// Loop video...
				display.seek(0);
				display.play();
			}
		}
		
		//***************************
		// Public methods:
		
		public function setData(i:Number, o:Object):void
		{
			// Save values
			index = i;
			data = o;
		
			// FLV
			display.autoPlay = false;
			display.source = data.@preview;
			display.addEventListener(VideoEvent.READY, readyHandler);
			display.addEventListener(VideoEvent.COMPLETE, completeHandler);
			
			// Listen to mouse interactions
			addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, rollOutHandler);
		}
		
		public function setActive(state:Boolean):void
		{
			enabled = state;
			alpha = state ? 1 : 0.15;
		}
		
		public function setHilight(b:Boolean):void
		{
			hilight_mc.visible = b;
		}
		
		public function playVideo():void
		{
			display.play();
		}
		
		public function pauseVideo():void
		{
			display.pause();
		}
		
		//***************************
		// Filtering methods:
		
		public function filterBy(filterType:Number, filterKey:Array):void
		{
			var filterMatchArr:Array;
			var filterMatched:Boolean = false;
			
			// Loop through filter type to see if we have a match
			switch( filterType )
			{
				case 1:
					// Examine filter1 for a match
					filterMatchArr = data.@filter1.toString().split(",");
					break;
				case 2:
					// Examine filter2 for a match
					filterMatchArr = data.@filter2.toString().split(",");
					break;
			}
			// Look for matches
			var len:uint = filterMatchArr.length;
			for(var n:uint=0; n<len; n++)
			{
				var len2:uint = filterKey.length;
				for(var j:uint=0; j<len2; j++)
				{
					if( filterMatchArr[n] == filterKey[j] ){
						filterMatched = true;
						break;
					}
				}
			}
			// Select or deselect this thumb
			setActive( filterMatched );
		}
	}
}