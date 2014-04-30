package
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.net.FileFilter;
	
	public class Editor extends MovieClip
	{
		const TILE_SIZE:int = 30;
		const TOOLBAR_OFFSET:int = 50;
		var tileArray:Array;
		var tileMap:Array;
		var container:Sprite;
		var map:Array;
		var activeTile:Tile;
		var grid:Sprite;
		
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
			drawGrid();
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
			importButton.y = stage.stageHeight - TILE_SIZE - 10;
			addChild(importButton);
			importButton.addEventListener(MouseEvent.CLICK, importButtonClicked);
			
			var exportBitmap:Bitmap = new Bitmap(new ExportArrow(13, 13));
			var exportButton:Sprite = new Sprite();
			exportButton.addChild(exportBitmap);
			
			exportButton.x = importButton.x + importButton.width + 4;
			exportButton.y = importButton.y;
			addChild(exportButton);
			exportButton.addEventListener(MouseEvent.CLICK, exportButtonClicked);
			
			var clrBitmap:Bitmap = new Bitmap(new Clear(30, 13));
			var clrButton:Sprite = new Sprite();
			clrButton.addChild(clrBitmap);
			
			clrButton.x = importButton.x;
			clrButton.y = importButton.y + importButton.height + 4;
			addChild(clrButton);
			clrButton.addEventListener(MouseEvent.CLICK, clearButtonClicked);
		}
		
		private function clearButtonClicked(e:MouseEvent):void 
		{
			generateEmptyMap();
			buildMap();
		}
		
		private function importButtonClicked(e:MouseEvent):void
		{
			var theFile:File = File.applicationDirectory;
			var typeFilter:FileFilter = new FileFilter("Text (.txt)", "*.txt");
			theFile.browseForOpen("Import Level", [typeFilter]);
			theFile.addEventListener(Event.SELECT, importMap);
		}
		
		private function importMap(e:Event):void
		{
			var stream:FileStream = new FileStream();
			stream.open(e.target as File, FileMode.READ);
			var data:String = stream.readUTFBytes(stream.bytesAvailable);
			
			var rowStrings:Array = String(data).split('\n');
			var rows:Array = [];
			
			for (var i:int = 0; i < rowStrings.length; i++)
			{
				var tmpRow:Array = [];
				for (var j:int = 0; j < rowStrings[i].length; j++)
				{
					if (j % 2 == 0)
						tmpRow.push(parseInt(rowStrings[i].charAt(j)));
				}
				rows.push(tmpRow);
			}
			map = rows;
			buildMap();
		}
		
		private function exportButtonClicked(e:MouseEvent):void
		{
			var theFile:File = File.applicationDirectory.resolvePath(".txt");
			theFile.browseForSave("Export Level");
			theFile.addEventListener(Event.SELECT, exportMap);
		}
		
		private function drawGrid():void
		{
			grid = new Sprite();
			grid.graphics.lineStyle(1, 0x002F2F);
			container.addChild(grid);
			grid.x--;
			grid.y--;
			var gRows:Number = 10;
			var gCols:Number = 15;
			var gW:Number = 30;
			var gH:Number = 30;
			var totalWidth:Number = gCols * gW;
			var totalHeight:Number = gRows * gH;
			
			// for loop for gCols
			
			for (var i:Number = 0; i <= gCols; i++)
			{
				grid.graphics.moveTo(gW * i, 0);
				grid.graphics.lineTo(gW * i, totalHeight);
			}
			
			// for loop for gRows
			
			for (var j:Number = 0; j <= gRows; j++)
			{
				grid.graphics.moveTo(0, gH * j);
				grid.graphics.lineTo(totalWidth, gH * j);
			}
		}
		
		private function exportMap(e:Event):void
		{
			var theFile:File = e.target as File;
			var stream:FileStream = new FileStream();
			stream.open(theFile, FileMode.WRITE);
			
			for (var i:int = 0; i < tileMap.length; i++)
			{
				for (var j:int = 0; j < tileMap[i].length; j++)
				{
					var data:int;
					var currentTile:Tile = tileMap[i][j];
					if (getDefinitionByName(getQualifiedClassName(currentTile)) == SkyTile)
						data = 1;
					else if (getDefinitionByName(getQualifiedClassName(currentTile)) == GrassTile)
						data = 0;
					else if (getDefinitionByName(getQualifiedClassName(currentTile)) == SpikeTile)
						data = 2;
					else if (getDefinitionByName(getQualifiedClassName(currentTile)) == DoorTile)
						data = 3;
					else if (getDefinitionByName(getQualifiedClassName(currentTile)) == StarTile)
						data = 4;
					
					stream.writeUTFBytes(String(data));
					stream.writeUTFBytes(" ");
					
				}
				stream.writeUTFBytes("\r\n");
			}
			stream.close();
		}
		
		private function handleToolbarClick(e:MouseEvent):void
		{
			if (mouseX > TOOLBAR_OFFSET)
				return;
			
			if (activeTile)
			{
				if (contains(activeTile))
					removeChild(activeTile);
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
			else
			{
				var replacement:Tile = new SkyTile();
				replacement.x = tileMap[yPos][xPos].x;
				replacement.y = tileMap[yPos][xPos].y;
				activeTile = tileMap[yPos][xPos];
				if (container.contains(activeTile))
					container.removeChild(activeTile);
				addChild(activeTile);
				
				container.addChild(replacement);
				
			}
		}
		
		private function update(e:Event):void
		{
			keepGridOnTop();
			if (!activeTile)
				return;
			activeTile.x = mouseX - (activeTile.width / 2);
			activeTile.y = mouseY - (activeTile.height / 2);
		}
		
		private function keepGridOnTop():void 
		{
			container.setChildIndex(grid, container.numChildren - 1);
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