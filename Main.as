package  
{
	import flash.display.MovieClip;

	public class Main extends MovieClip 
	{
		
		public function Main() 
		{
			var app:Editor = new Editor();
			addChild(app);
			app.init();
		}
		
	}

}