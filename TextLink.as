package fvg
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;  
	import flash.text.TextField;
	
	/******************************
	* TextLink class:
	* Extends MovieClip to create a clickable text 
	* link with a rollover state.
	* -----------------------------
	* Developed by Dan Carr (dan@dancarrdesign.com) 
	* For Adobe Systems, Inc. - Adobe Developer Center
	* Last modified: Septembed 18, 2009
	*/
	public class TextLink extends MovieClip
	{
		//***************************
		// Properties:
		
		public var label		:String;
		public var url			:String;
		public var offset		:Number = 8;
		
		//***************************
		// Intialization:
		
		public function TextLink(){
			// Construct!
		}
		
		//***************************
		// Handle events:
		
		protected function rollOverHandler(event:MouseEvent):void
		{
			if( enabled )
			{
				lbl.background = true;
				lbl.backgroundColor = 0xddeeff;
			}
		}
		
		protected function rollOutHandler(event:MouseEvent):void
		{
			if( enabled )
			{
				lbl.background = false;
			}
		}
		
		//***************************
		// Public methods:
		
		public function setData(l:String, u:String):void
		{
			if( u != null){
				url = u;
			}else{
				lbl.textColor = 0x000000;
			}
			lbl.autoSize = "left";
			lbl.htmlText = label = l;
			lbl.width = lbl.textWidth + offset;
			lbl.addEventListener(MouseEvent.MOUSE_OVER, rollOverHandler,false,0,true);
			lbl.addEventListener(MouseEvent.MOUSE_OUT, rollOutHandler,false,0,true);
		}
	}
}