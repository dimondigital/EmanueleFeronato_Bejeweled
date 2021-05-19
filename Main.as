package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.*;
	
	public class Main extends Sprite {
		private var jewels:Array = new Array();
		private var gemsContainer:Sprite = new Sprite();
		private var gem:gem_mc;	
		var glowFilt:GlowFilter = new GlowFilter(0xFFFFFF, 1, 15, 15, 1, 1);
		private var selector:selector_mc = new selector_mc();
		private var pickedRow:int=-10;
		private var pickedCol:int=-10;
		
		public function Main () {
			jewelsInit();
			addChild(selector);
			selector.visible = false;
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		
		private function onClick(e:MouseEvent):void {
		  if (mouseX<480&&mouseX>0&&mouseY<480&&mouseY>0) {
			var selRow:uint=Math.floor(mouseY/60);
			var selCol:uint=Math.floor(mouseX/60);
			if (! isAdjacent(selRow,selCol,pickedRow,pickedCol)) {
			  pickedRow=selRow;
			  pickedCol=selCol;
			  selector.x=60*pickedCol;
			  selector.y=60*pickedRow;
			  selector.visible=true;
			} else {
			  swapJewelsArray(pickedRow,pickedCol,selRow,selCol);
			  if (isStreak(pickedRow,pickedCol)||isStreak(selRow,selCol)) {
				  swapJewelsObject(pickedRow,pickedCol,selRow,selCol);
				  if (isStreak(pickedRow,pickedCol)) {
					  removeGems(pickedRow,pickedCol);
				  }
				  if (isStreak(selRow,selCol)) {
					  removeGems(selRow,selCol);
				  }
			  }else{
				  swapJewelsArray(pickedRow,pickedCol,selRow,selCol);
			  }
				  pickedRow=-10;
				  pickedCol=-10;
				  selector.visible=false;
			  }
		  }
		}
		
		
		private function jewelsInit():void {
			addChild(gemsContainer);
			for (var i:uint=0; i<8; i++) {
				jewels [i]= new Array();
				for (var j:uint=0; j<8; j++) {
					do {
					jewels[i] [j] = Math.floor(Math.random()*7);
					} while (isStreak(i, j));
					gem = new gem_mc(jewels[i] [j], i, j);
					gem.filters = [glowFilt];
					gemsContainer.addChild(gem);
				}
			}
		}
		
		
		private function checkGem (gem:uint, row:int, col:int):Boolean {
			if (jewels [row] == null ) {
				return false;
			}
			if (jewels [row] [col] == null) {
				return false
			}
			return gem==jewels [row] [col];
		}
		
		
		private function rowStreak(row:uint, col:uint):uint {
			var current:uint = jewels [row] [col];
			var streak:uint = 1;
			var tmp:int = col;
			while (checkGem(current, row, tmp-1)) {
				tmp--;
				streak++;
			}
			tmp=col;
			while (checkGem(current, row, tmp+1)) {
				tmp++;
				streak++;
			}
			return (streak);
		}
		
		
		private function colStreak (row:uint, col:uint):uint {
			var current:uint = jewels [row] [col];
			var streak:uint =1;
			var tmp:int=row;
			while (checkGem(current, tmp-1, col)) {
				   tmp--;
				   streak++;
			}
			tmp=row;
			while (checkGem(current, tmp+1, col)) {
				tmp++;
				streak++;
			}
			return (streak);
		}
		
		
		private function isStreak(row:uint, col:uint):Boolean {
			return rowStreak(row, col)>2||colStreak(row, col)>2;
		}
		
		
		private function isAdjacent(row1:int,col1:int,row2:int,col2:int):Boolean {
		  return Math.abs(row1-row2)+Math.abs(col1-col2)==1
		}
		
		
		private function swapJewelsArray(row1:uint,col1:uint,row2:uint,col2:uint):void {
			var tmp:uint=jewels[row1][col1];
			jewels[row1][col1]=jewels[row2][col2];
			jewels[row2][col2]=tmp;
		}
		
		
		private function swapJewelsObject(row1:uint,col1:uint,row2:uint,col2:uint):void {
		  with (gemsContainer.getChildByName(row1+"_"+col1)) {
			x=col2*60;
			y=row2*60;
			name="tmp";
		  }
		  with (gemsContainer.getChildByName(row2+"_"+col2)) {
			x=col1*60;
			y=row1*60;
			name=row1+"_"+col1;
		  }
		  gemsContainer.getChildByName("tmp").name=row2+"_"+col2;
		}
		
		
		private function removeGems(row:uint,col:uint):void {
		  var gemsToRemove:Array=[row+"_"+col];
		  var current:uint=jewels[row][col];
		  var tmp:int;
		  if (rowStreak(row,col)>2) {
			tmp=col;
			while (checkGem(current,row,tmp-1)) {
			  tmp--;
			  gemsToRemove.push(row+"_"+tmp);
			}
			tmp=col;
			while (checkGem(current,row,tmp+1)) {
			  tmp++;
			  gemsToRemove.push(row+"_"+tmp);
			}
		  }
		  if (colStreak(row,col)>2) {
			tmp=row;
			while (checkGem(current,tmp-1,col)) {
			  tmp--;
			  gemsToRemove.push(tmp+"_"+col);
			}
			tmp=row;
			while (checkGem(current,tmp+1,col)) {
			  tmp++;
			  gemsToRemove.push(tmp+"_"+col);
			}
		  }
		  trace("Will remove "+gemsToRemove);
		  gemsToRemove.forEach(removeTheGem);
		  adjustGems();
		  replaceGems();
		}
		
		
		private function removeTheGem(element:String,index:int,arr:Array):void 
		{
		  with (gemsContainer) {
			removeChild(getChildByName(element));
		  }
		  var coordinates:Array=element.split("_");
		  jewels[coordinates[0]][coordinates[1]]=-1;
		}
		
		
		private function adjustGems():void {
		  for (var j:uint=0; j<8; j++) {
			for (var i:uint=7; i>0; i--) {
			  if (jewels[i][j]==-1) {
				for (var k:uint=i; k>0; k--) {
				  if (jewels[k][j]!=-1) {
					break;
				  }
				}
				if (jewels[k][j]!=-1) {
				  trace("moving gem at row "+k+" to row "+i);
				  jewels[i][j]=jewels[k][j];
				  jewels[k][j]=-1;
				  with(gemsContainer.getChildByName(k+"_"+j)){
					y=60*i;
					name=i+"_"+j;
				  }
				  if (isStreak(i, j)) {
					  trace("COMBO");
					  removeGems(i, j);
				  }
				}
			  }
			}
		  }
		}
		
		private function replaceGems():void {
		  for (var i:int=7; i>=0; i--) {
			for (var j:uint=0; j<8; j++) {
			  if (jewels[i][j]==-1) {
				jewels[i][j]=Math.floor(Math.random()*7);
				gem=new gem_mc(jewels[i][j],i,j);
				gemsContainer.addChild(gem);
				if (isStreak(i, j)) {
					trace("COMBO");
					removeGems(i, j);
				}
			  }
			}
		  }
		}
		
		
	}
}