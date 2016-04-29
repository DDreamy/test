package fvg
{
	import flash.net.*;  
	import flash.display.*;
	import flash.events.*;  
	import flash.text.TextField;
	import flash.external.ExternalInterface;
	import fl.controls.CheckBox;
	import fl.controls.RadioButton;   
	import fl.video.*;
	import fvg.*;
	
	/******************************
	* FlashVideoGallery class:
	* Extends MovieClip to act as a manager class for the video 
	* gallery application. This object loads XML data, initializes 
	* it in its sub-objects, and handles events from the sub-objects...
	* -----------------------------
	* Developed by Dan Carr (dan@dancarrdesign.com) 
	* For Adobe Systems, Inc. - Adobe Developer Center
	* Last modified: November 20, 2008
	*/
	public class FlashVideoGallery extends MovieClip
	{
		//***************************
		// HTTP:
		
		protected var loader					:URLLoader;
		protected var settings					:XML;
		protected var settingsPath				:String = "Settings.xml";
		
		// JavaScript params: 
		protected var documentHref				:String = "";
		protected var documentHrefVars			:Object = new Object();
		
		// Thumbnail layout:
		protected var thumbXBegin				:Number = 53;
		protected var thumbYBegin				:Number = 62;
		protected var thumbXSpacing				:Number = 1;
		protected var thumbYSpacing				:Number = 1;
		protected var thumbsPerRow				:Number = 6;
		protected var thumbsLoaded				:Number = 0;
		protected var thumbsTotal				:Number = 0;
		protected var thumbs					:Array = new Array();
		
		// Filter lookup
		protected var currentFilterGroup		:Number = 1;
		protected var filterMaxLength			:Number = 2;
		protected var filterOptionsMaxLength	:Number = 4;
		
		// Detail view:
		protected var detailView				:DetailView;
		protected var detailViewX  				:Number = 471;
		protected var detailViewY  				:Number = 33;
		
		// Current thumb:
		protected var currentItem				:*;
		protected var selectedItem				:*;
		
		// Assets
		protected var tooltip					:Tooltip;
		
		//***************************
		// Intialization:
		
		public function FlashVideoGallery()
		{
			// Get href from JavaScript container
			documentHref = String(ExternalInterface.call("getDocumentLocation"));
			
			// Parse variables from the URL string
			var hrefArr1:Array = documentHref.split("/");
			var hrefArr2:Array = hrefArr1[hrefArr1.length - 1].split("?");
			if( hrefArr2.length > 1 )
			{
				var hrefVars:Array = hrefArr2[1].split("&");
				var hrefVarsLen:uint = hrefVars.length;
				for(var n:uint = 0; n < hrefVarsLen; n++) 
				{
					var hrefVar:Array = hrefVars[n].split("=");
					switch( hrefVar[0] ) 
					{
						case "debug":
							loading_mc.visible = false;
							break;
						case "settings":
							settingsPath = hrefVar[1];
							break;
						case "video": 
							hrefVar[1] = Number(hrefVar[1]);
							break;
					}
					documentHrefVars[hrefVar[0]] = hrefVar[1];
				}
			}
			
			// Load data!
			loader = new URLLoader();
			loader.load(new URLRequest(settingsPath));
			loader.addEventListener(Event.COMPLETE, onDataHandler);
		}
		
		//***************************
		// Event handlers:
		
		// Data loaded
		protected function onDataHandler(event:Event):void
		{
			settings = new XML(loader.data);
			thumbsTotal = settings.videos.video.length();
			layout();
		}
		
		// Thumbnail loaded
		protected function thumbReadyHandler(event:VideoEvent):void
		{
			thumbsLoaded++;
			
			// Hide loading screen when all thumbs have loaded...
			if( thumbsLoaded == thumbsTotal )
			{
				// Launch default video
				if( documentHrefVars.video != undefined ) 
				{
					// Set selection
					selectedItem = currentItem = thumbs[documentHrefVars.video];
					selectedItem.setHilight(true);
					
					// Load a video detail
					showDetail(true, documentHrefVars.video);
				}
				// Show the screen
				loading_mc.visible = false;
			}
		}
		
		// Thumbnail rollOver
		protected function thumbOverHandler(event:MouseEvent):void
		{  
			// Set current item
			currentItem = event.currentTarget;
			setChildIndex(currentItem, numChildren - 1);
			
			// Set tooltip
			if( tooltip == null ){
				tooltip = new Tooltip();
			}
			tooltip.x = root.mouseX;
			tooltip.y = root.mouseY;
			tooltip.setLabel(settings.videos.video[currentItem.index].title);
			addChild(tooltip);
			
			// Listen for mousemove
			addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		}
		
		// Tooltip move
		protected function moveHandler(event:MouseEvent):void
		{
			tooltip.x = root.mouseX;
			tooltip.y = root.mouseY;
		}
		
		// Thumbnail rollOut
		protected function thumbOutHandler(event:MouseEvent):void
		{  
			// Remove tooltip
			removeChild(tooltip);
			
			// Remove mousemove listener
			removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		}
			
		// Thumbnail clicked
		protected function thumbClickHandler(event:MouseEvent):void
		{   
			// Remove previous hilite
			if( selectedItem != null ){
				selectedItem.setHilight(false);
			}
			// Set selection
			selectedItem = event.currentTarget;
			selectedItem.setHilight(true);
			
			// Load a video detail
			showDetail(true, selectedItem.index);
		}
		
		// DetailView closed
		protected function detailCloseHandler(event:Event):void
		{
			// Remove selection
			selectedItem.setHilight(false);
			selectedItem = null;
			
			// Close detail view
			showDetail(false, -1);
		}
		
		// Filter clicked
		protected function filterClickHandler(event:MouseEvent):void
		{
			// Find which filter group to use (Radio button)
			for(var j:uint=0; j<filterMaxLength; j++)
			{
				var radio:String = "radio"+(j+1);
				if( getChildByName(radio) != null )
				{
					if( this[radio].selected ){
						currentFilterGroup = j+1;
						break;
					}
				}
			}
			// Get selections (Related checkboxes)
			var filterByArr:Array = new Array();
			for(var n:uint=0; n<filterOptionsMaxLength; n++)
			{
				var check:String = "checkbox"+(currentFilterGroup == 2 ? (n+1+filterOptionsMaxLength) : n+1);
				if( getChildByName(check) != null )
				{
					if( this[check].selected ){
						filterByArr.push(settings.filters[currentFilterGroup-1].filter[n+1].@id);
					}
				}
			}
			// Set filters on thumbnails
			for(var i:uint=0; i<thumbsTotal; i++){
				thumbs[i].filterBy(currentFilterGroup,filterByArr);
			}
		}
			
		// Link clicked
		protected function linkClickHandler(event:MouseEvent):void
		{
			// Call URL...
			var url = event.currentTarget.url;
			navigateToURL(new URLRequest(url), "_self");
		}
		
		//***************************
		// Layout:
			
		protected function layout():void
		{
			// 1. TEXTFIELDS (Set labels)
			for each(var prop1:XML in settings.labels.label )
			{
				// Set labels if a matching object exists
				if( getChildByName(prop1.@name) != null ){
					this[prop1.@name].htmlText = prop1;
				}
			}
			
			// 2. LINKS (Set links on main screen)
			for each(var prop2:XML in settings.links.link )
			{
				// Set labels if a matching object exists
				if( getChildByName(prop2.@name) != null ){
					this[prop2.@name].setData(prop2, prop2.@url);
					this[prop2.@name].addEventListener(MouseEvent.CLICK, linkClickHandler);
				}
			}
			
			// 3. FILTER 1 (Layout filter 1 labels)
			for each(var prop3:XML in settings.filters[0].filter )
			{
				if( getChildByName(prop3.@name) != null ){
					if( String(prop3).length > 0 ){
						this[prop3.@name].label = prop3;
						this[prop3.@name].selected = (prop3.@view == 1) ? true : false;
						this[prop3.@name].addEventListener(MouseEvent.CLICK, filterClickHandler);
					}else{
						this[prop3.@name].visible = false;
					}
				}
			}
			
			// 4. FILTER 2 (Layout filter 2 labels)
			for each(var prop4:XML in settings.filters[1].filter )
			{
				if( getChildByName(prop4.@name) != null ){
					if( String(prop4).length > 0 ){
						this[prop4.@name].label = prop4;
						this[prop4.@name].selected = (prop4.@view == 1) ? true : false;
						this[prop4.@name].addEventListener(MouseEvent.CLICK, filterClickHandler);
					}else{
						this[prop4.@name].visible = false;
					}
				}
			}
			
			// 5. DETAIL VIEW (Create detail clip below thumbnails)
			detailView = new DetailView();
			detailView.x = detailViewX;
			detailView.y = detailViewY;
			detailView.visible = false;
			detailView.addEventListener(Event.CLOSE, detailCloseHandler);
			addChild(detailView);
			
			// 6. THUMBNAILS (Layout the video thumbnails) 
			var i:uint = 0;
			for each(var prop5:XML in settings.videos.video )
			{
				var deltaX:Number = i - Math.floor(i / thumbsPerRow) * thumbsPerRow;
				var deltaY:Number = Math.floor(i / thumbsPerRow);
				var data:XML = settings.videos.video[i];
				thumbs[i] = new VideoThumbnail();
				thumbs[i].x = deltaX * (thumbs[i].width + thumbXSpacing) + thumbXBegin;
				thumbs[i].y = deltaY * (thumbs[i].height + thumbYSpacing) + thumbYBegin;
				thumbs[i].setData(i, data);
				thumbs[i].addEventListener(VideoEvent.READY, thumbReadyHandler);
				thumbs[i].addEventListener(MouseEvent.MOUSE_OVER, thumbOverHandler);
				thumbs[i].addEventListener(MouseEvent.MOUSE_OUT, thumbOutHandler);
				thumbs[i].addEventListener(MouseEvent.CLICK, thumbClickHandler);
				addChild(thumbs[i]);
				i++;
			}
			
			// Set loading screen to top depth
			setChildIndex(loading_mc, numChildren - 1);
		}
		
		//***************************
		// Load video details:
		
		public function showDetail(state:Boolean, index:Number):void
		{
			// Show or hide the detail
			if( state ){
				var labels = settings.labels.label;
				var details = settings.videos.video[index];
				
				// Set data!
				detailView.setData(labels, details);
			}else{
				detailView.reset();
			}
			detailView.visible = state;
		}
	}
}