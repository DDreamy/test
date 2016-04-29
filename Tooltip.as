package fvg
{
	import flash.text.TextField;
	import flash.display.Sprite;
	
	/******************************
	* Tooltip class:
	* Extends Sprite to create a tooltip display
	* for the video thumbnails.
	* -----------------------------
	* Developed by Dan Carr (dan@dancarrdesign.com) 
	* For Adobe Systems, Inc. - Adobe Developer Center
	* Last modified: November 24, 2008
	*/
	public class Tooltip extends Sprite
	{
		//***************************
		// Properties:
		
		protected var text:String = "";
		
		//***************************
		// Intialization:
		
		public function Tooltip()
		{
			// Construct!
			lbl.autoSize = "left";
		}
		
		//***************************
		// Public methods:
		
		public function setLabel(l:String):void
		{
			lbl.htmlText = text = l;
			skin_mc.width = Math.round(lbl.textWidth) + 22;
		}
	}
}