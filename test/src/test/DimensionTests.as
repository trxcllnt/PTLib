package test
{
    import org.flexunit.assertThat;
    import com.pt.virtual.Dimension;

    public class DimensionTests
    {
        private var dimension:Dimension;
        
        [Before]
        public function setUp():void
        {
            dimension = new Dimension();
        }
        
        [After]
        public function tearDown():void
        {
            dimension = null;
        }
        
        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }
        
        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }
        
        [Test]
        public function add_item():void
        {
            var obj:Object = {};
            dimension.add(obj, 1);
        }
        
        [Test]
        public function remove_item():void
        {
            var obj:Object = {};
            dimension.add(obj, 1);
            dimension.remove(obj);
        }
        
        [Test]
        public function item_is_removed():void
        {
            var obj:Object = {};
            dimension.add(obj, 1);
            dimension.remove(obj);
            var items:Array = dimension.getItems();
            assertThat(items.length == 0);
        }
        
        [Test]
        public function get_item_at_exact_first_index():void
        {
            var obj:Object = {};
            dimension.add(obj, 1);
            assertThat(dimension.getAt(0) == obj);
        }
        
        [Test]
        public function add_item_with_zero_size_converts_to_one():void
        {
            var obj:Object = {};
            dimension.add(obj, 0);
            assertThat(dimension.getAt(0) == obj);
        }
        
        [Test]
        public function get_item_at_exact_arbitrary_index():void
        {
            var obj:Object = {};
            dimension.add({}, 1);
            dimension.add(obj, 1);
            assertThat(dimension.getAt(1) == obj);
        }
        
        [Test]
        public function get_item():void
        {
            var obj:Object = {};
            var obj2:Object = {};
            
            dimension.add(obj, 10);
            dimension.add(obj2, 10);
            
            assertThat(dimension.getAt(5) == obj);
            assertThat(dimension.getAt(15) == obj2);
        }
        
        [Test]
        public function get_items_returns_all_items():void
        {
            var obj:Object = {};
            var obj2:Object = {};
            var obj3:Object = {};
            dimension.add(obj, 5);
            dimension.add(obj2, 5);
            dimension.add(obj3, 5);
            var items:Array = dimension.getItems();
            assertThat(items.length == 3);
            assertThat(items.indexOf(obj) != -1);
            assertThat(items.indexOf(obj2) != -1);
            assertThat(items.indexOf(obj3) != -1);
        }
        
        [Test]
        public function get_items_at_returns_all_items():void
        {
            var obj:Object = {};
            var obj2:Object = {};
            var obj3:Object = {};
            dimension.add(obj, 5);
            dimension.add(obj2, 5);
            dimension.add(obj3, 5);
            var items:Array = dimension.getBetween(0, 15);
            assertThat(items.length == 3);
            assertThat(items.indexOf(obj) != -1);
            assertThat(items.indexOf(obj2) != -1);
            assertThat(items.indexOf(obj3) != -1);
        }
        
        [Test]
        public function get_items_returns_items_inclusively():void
        {
            var obj:Object = {};
            var obj2:Object = {};
            var obj3:Object = {};
            
            dimension.add(obj, 5);
            dimension.add(obj2, 5);
            dimension.add(obj3, 5);
            
            var items:Array = dimension.getBetween(3, 12);
            assertThat(items.length == 3);
            
            assertThat(items.indexOf(obj) != -1);
            assertThat(items.indexOf(obj2) != -1);
            assertThat(items.indexOf(obj3) != -1);
        }
        
        [Test]
        public function add_item_again_reorders_list():void
        {
            var obj:Object = {};
            var obj2:Object = {};
            
            dimension.add(obj, 5);
            dimension.add(obj2, 5);
            
            var items:Array = dimension.getItems();
            
            assertThat(items.length == 2);
            assertThat(items[0] == obj);
            assertThat(items[1] == obj2);
            
            dimension.add(obj, 5);
            
            items = dimension.getItems();
            
            assertThat(items.length == 2);
            assertThat(items[0] == obj2);
            assertThat(items[1] == obj);
        }
        
        [Test]
        public function add_item_at_with_no_items_calls_add_item():void
        {
            var obj:Object = {};
            dimension.addAt(obj, 0);
            assertThat(dimension.getAt(0) == obj);
        }
        
        [Test]
        public function add_item_at__works_with_multiple_items():void
        {
            var obj:Object = {};
            var obj2:Object = {};
            
            dimension.addAt(obj, 0, 1);
            dimension.addAt(obj2, 1, 1);
            
            var items:Array = dimension.getItems();
            
            assertThat(items.length == 2);
            assertThat(items[0] == obj);
            assertThat(items[1] == obj2);
        }
        
        [Test]
        public function add_item_at_reorders_items():void
        {
            var obj:Object = {};
            var obj2:Object = {};
            var obj3:Object = {};
            
            dimension.addAt(obj, 0, 1);
            dimension.addAt(obj2, 1, 1);
            dimension.addAt(obj3, 2, 1);
            
            var items:Array = dimension.getItems();
            
            assertThat(items.length == 3);
            assertThat(items[0] == obj);
            assertThat(items[1] == obj2);
            assertThat(items[2] == obj3);
            
            dimension.addAt(obj3, 1);
            
            items = dimension.getItems();
            
            assertThat(items.length == 3);
            assertThat(items[0] == obj);
            assertThat(items[1] == obj3);
            assertThat(items[2] == obj2);
            
            items = dimension.getBetween(0, 3);
            
            assertThat(items.length == 3);
            assertThat(items[0] == obj);
            assertThat(items[1] == obj3);
            assertThat(items[2] == obj2);
        }
        
        [Test]
        public function add_item_at_incongruent_positions_correctly():void
        {
            var obj:Object = {};
            var obj2:Object = {};
            var obj3:Object = {};
            
            dimension.allowOverlap = false;
            
            dimension.addAt(obj, 0, 10);
            dimension.addAt(obj2, 15, 10);
            dimension.addAt(obj3, 30, 10);
            
            var items:Array = dimension.getItems();
            
            assertThat(items.length == 3);
            assertThat(items[0] == obj);
            assertThat(items[1] == obj2);
            assertThat(items[2] == obj3);
        }
    }
}