using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Elements;
using Fuse.Controls;
using Fuse.Reactive;
using Fuse.Resources;

public enum Direction
{
	Up, Down, Left, Right
}

public class Cell : Image
{
	public Cell()
	{

	}
}

public class VirtualisationPanel : Behavior, IObserver
{

	Panel _parent;

	int _itemsCount = 0;
	public int ItemsCount
	{
		get { return _itemsCount; }
		set { _itemsCount = value; }
	}

	int _visibleCount = 3;
	public int VisibleCount
	{
		get { return _visibleCount; }
		set { _visibleCount = value; }
	}

	float _speed = 1f;
	public float Speed
	{
		get { return _speed; }
		set { _speed = value; }
	}

	Direction _direction = Direction.Down;
	public Direction Direction
	{
		get { return _direction; }
		set { _direction = value; }
	}

	public float ItemHeight { get; set; }

	bool _running;
	public bool Running
	{
		get { return _running; }
		set
		{
			if (value != _running && value)
				UpdateManager.AddAction(OnUpdate);
			else if (value != _running && !value)
				UpdateManager.RemoveAction(OnUpdate);
			_running = value;
		}
	}

	object _items;
	public object Items
	{
		get { return _items; }
		set
		{
		   _items = value;
		   OnItemsChanged();
		}
	}



	List<string> _data = new List<string>();
	int _index = 0;

	Translation _translation = new Translation();

	protected override void OnRooted(Node parentNode)
	{
		base.OnRooted(parentNode);
		if (!(parentNode is Panel))
			throw new Exception("VirtualisationPanel can only be added to Panel types");
		_parent = (Panel)parentNode;
		_parent.Transforms.Add(_translation);
	}



	float2 DirectionVector
	{
		get
		{
			int x = 0, y = 0;
			if (Direction == Direction.Left){ x = -1; }
			else if (Direction == Direction.Right){ x = 1; }
			else if (Direction == Direction.Up){ y = -1; }
			else if (Direction == Direction.Down){ y = 1; }
			return float2(x,y);
		}
	}

	void UpdatePosition(float dt)
	{
		var vector = DirectionVector * dt * _speed;
		_translation.X += vector.X;
		_translation.Y += vector.Y;

		if (_translation.Y > ItemHeight)
		{
			_translation.Y -= ItemHeight;
			_index += 1;

			IndexChanged();
		}
	}

	void OnUpdate()
	{
		UpdatePosition((float)Time.FrameInterval);
	}

	IDisposable _subscription;
	void OnItemsChanged()
	{
		debug_log("ItemType: " + _items.GetType());
		var obs = _items as IObservable;



		if (obs != null)
		{
			if (_subscription != null) _subscription.Dispose();
			_subscription = obs.Subscribe(this);
		}
	}



	void DataChanged()
	{
		debug_log("Data was changed");
	}

	bool Acceptor(object o)
	{
		return o is FileImageSource;
	}

	void IndexChanged()
	{
		if (_data.Count == 0) return;
		var i = 0;

		foreach (var c in _parent.Children)
		{
			var cell = c as Cell;
			if (cell != null)
			{
				var key = _data[Math.Abs(i - _index) % _data.Count];
				object fileSource;
				if (_parent.TryGetResource(key, Acceptor, out fileSource))
				{
					var fileImageSource = fileSource as FileImageSource;
					if (fileImageSource != null)
					{
						cell.Source = fileImageSource;
					}
				}

			}
			i++;
		}
	}

	void ReplaceAll(object[] dcs)
	{
		_data.Clear();

		if (dcs != null)
		{
			foreach (var d in dcs)
			{
				debug_log("DC: " + d);
				var dataString = d as string;
				if (dataString != null)
					_data.Add(dataString);
			}
			DataChanged();
		}

	}

	void Repopulate()
	{
		var e = _items as object[];
		if (e != null)
		{
			ReplaceAll(e);
		}
		else
		{
			var a = _items as IAsyncArray;
			if (a != null)
			{
				a.Enum(Dispatcher.UIThread, ReplaceAll);
			}
		}
	}

	void IObserver.OnNewAll(int length)
	{
		debug_log("OnNewAll: " + length);
		Repopulate();
	}
	void IObserver.OnNewAt(int index, object newValue)
	{
		debug_log("OnNewAt: " + index + ", " + newValue);
		debug_log("type: " + newValue.GetType());
	}
	void IObserver.OnSet(object newValue)
	{
		debug_log("OnSet: " + newValue);
	}
	void IObserver.OnAdd(object addedValue)
	{
		debug_log("OnAdd: " + addedValue);
	}
	void IObserver.OnRemove(object value, int index)
	{
		debug_log("OnRemove: " + value + ", " + index);
	}
	void IObserver.OnInsertAt(int index, object value)
	{
		debug_log("OnInsertAt: " + index + ", " + value);
	}
	void IObserver.OnFailed(string message)
	{
		debug_log("OnFailed: " + message);
	}
}