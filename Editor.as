package  
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class Editor extends MovieClip 
	{
		const TILE_SIZE:int = 30;
		const TOOLBAR_OFFSET:int = 50;
		var tileArray:Array;
		var tileMap:Array;
		var container:Sprite;
		var map:Array;
		var activeTile:Tile;
		
		public function Editor() { }
		
		public function init():void {
			tileArray = [GrassTile, SkyTile, SpikeTile, DoorTile, StarTile];
			container = new Sprite();
			container.x = TOOLBAR_OFFSET;
			addChild(container);
			container.addEventListener(MouseEvent.CLICK, handleContainerClick);
			addEventListener(Event.ENTER_FRAME, update);
			initToolbar();
			generateEmptyMap();
			buildMap();
		}
		
		private function handleContainerClick(e:MouseEvent):void 
		{
			var xPos:int = (50 + mouseX) / TILE_SIZE;
			xPos -= 3;
			if (xPos == 15)		xPos = 14;
			var yPos:int = mouseY / TILE_SIZE;
			container.removeChild(tileMap[yPos][xPos]);
		}
		
		private function initToolbar():void 
		{
			for (var i:int = 0; i < tileArray.length; i++) 
			{
				var tmpClass:Class = tileArray[i];
				var tmpTile:Tile = new tmpClass();
				
				tmpTile.x = 10;
				tmpTile.y = 10 + ((tmpTile.height + 10)* i);
				addChild(tmpTile);
				tmpTile.addEventListener(MouseEvent.CLICK, handleToolbarClick);
			}
		}
		
		private function handleToolbarClick(e:MouseEvent):void 
		{	
			var pos:Number = mouseY / (TILE_SIZE + 10)
			trace(pos);
			
			if (pos > 0.25 && pos < 1)
				activeTile = new GrassTile();
			else if (pos > 1.25 && pos < 2)
				activeTile = new SkyTile();
			else if (pos > 2.25 && pos < 3)
				activeTile = new SpikeTile();
			else if (pos > 3.25 && pos < 4)
				activeTile = new DoorTile();
			else if (pos > 4.25 && pos < 5)
				activeTile = new StarTile();
				
			activeTile.x = mouseX - (activeTile.width / 2);
			activeTile.y = mouseY - (activeTile.height / 2);
			addChild(activeTile);
		}
		
		private function update(e:Event):void 
		{
			if (!activeTile)
				return;
			activeTile.x = mouseX - (activeTile.width / 2);
			activeTile.y = mouseY - (activeTile.height / 2);
		}
		
		private function generateEmptyMap():void
		{
			map = [];
			for (var i:int = 0; i < 10; i++) 
			{
				var tmpRow:Array = [];
				for (var j:int = 0; j < 15; j++) 
				{
					tmpRow.push(1);
				}
				map.push(tmpRow);
			}
		}
		
		private function buildMap():void
		{
			tileMap = [];
			
			for (var i:int = 0; i < map.length; i++)
			{
				var row:Array = [];
				
				for (var j:int = 0; j < map[i].length; j++)
				{
					var tileType:int = map[i][j];
					var className:Class = tileArray[tileType];
					var tile:Tile = new className();
					
					container.addChild(tile);
					tile.x = tile.width * j;
					tile.y = tile.height * i;
					row.push(tile);
				}
				tileMap.push(row);
			}
		}
	}

}