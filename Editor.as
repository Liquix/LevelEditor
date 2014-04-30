package
{
	import flash.display.Bitmap;
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
		
		public function Editor()
		{
		}
		
		public function init():void
		{
			tileArray = [GrassTile, SkyTile, SpikeTile, DoorTile, StarTile];
			container = new Sprite();
			addChild(container);
			container.x = TOOLBAR_OFFSET;
			addEventListener(Event.ENTER_FRAME, update);
			stage.addEventListener(MouseEvent.CLICK, handleToolbarClick);
			initToolbar();
			generateEmptyMap();
			buildMap();
		}
		
		private function handleTileRelease(e:MouseEvent):void
		{
			var xPos:int = (TOOLBAR_OFFSET + mouseX) / TILE_SIZE;
			xPos -= 3;
			if (xPos == 15)
				xPos = 14;
			var yPos:int = mouseY / TILE_SIZE;
			var tmpTile:Tile = tileMap[yPos][xPos];
			removeChild(tileMap[yPos][xPos]);
			tileMap[yPos][xPos] = activeTile;
			activeTile.x = tmpTile.x;
			activeTile.y = tmpTile.y;
			activeTile = null;
		}
		
		private function initToolbar():void
		{
			for (var i:int = 0; i < tileArray.length; i++)
			{
				var tmpClass:Class = tileArray[i];
				var tmpTile:Tile = new tmpClass();
				
				tmpTile.x = 10;
				tmpTile.y = 10 + ((tmpTile.height + 10) * i);
				addChild(tmpTile);
				
			}
			
			var importBitmap:Bitmap = new Bitmap(new ImportArrow(13, 13));
			var importButton:Sprite = new Sprite();
			importButton.addChild(importBitmap);
			
			importButton.x = 10;
			importButton.y = stage.stageHeight - importButton.height - 10;
			addChild(importButton);
			importButton.addEventListener(MouseEvent.CLICK, importMap);
			
			var exportBitmap:Bitmap = new Bitmap(new ExportArrow(13, 13));
			var exportButton:Sprite = new Sprite();
			exportButton.addChild(exportBitmap);
			
			exportButton.x = importButton.x + importButton.width + 3;
			exportButton.y = importButton.y;
			addChild(exportButton);
			exportButton.addEventListener(MouseEvent.CLICK, exportMap);
		}
		
		private function importMap(e:MouseEvent):void 
		{
			trace("Import");
		}
		
		private function exportMap(e:MouseEvent):void 
		{
			trace("Export");
		}
		
		private function handleToolbarClick(e:MouseEvent):void
		{
			if (mouseX > TOOLBAR_OFFSET)
				return;
			
			if (activeTile) {
				if (contains(activeTile))	removeChild(activeTile);
				activeTile = null;
				return;
			}
			
			var pos:Number = mouseY / (TILE_SIZE + 10)
			
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
			else
				return;
			
			activeTile.x = mouseX - (activeTile.width / 2);
			activeTile.y = mouseY - (activeTile.height / 2);
			addChild(activeTile);
			activeTile.addEventListener(MouseEvent.CLICK, handleTileClick);
		}
		
		private function handleTileClick(e:MouseEvent):void
		{
			if (mouseX < TOOLBAR_OFFSET)
				return;
				
			var xPos:int = ((50 + mouseX) / TILE_SIZE) - 3;
			if (xPos == 15)
				xPos = 14;
			var yPos:int = mouseY / TILE_SIZE;
				
			if (activeTile)
			{
				var tmpTile:Tile = tileMap[yPos][xPos];
				container.removeChild(tileMap[yPos][xPos]);
				tileMap[yPos][xPos] = activeTile;
				
				if (contains(activeTile))
					removeChild(activeTile);
				container.addChild(activeTile);
				activeTile.x = tmpTile.x;
				activeTile.y = tmpTile.y;
				activeTile = null;
			}
			else {
				var replacement:Tile = new SkyTile();
				replacement.x = tileMap[yPos][xPos].x;
				replacement.y = tileMap[yPos][xPos].y;
				activeTile = tileMap[yPos][xPos];
				if(container.contains(activeTile))	container.removeChild(activeTile);
				addChild(activeTile);
				
				container.addChild(replacement);
				
			}
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