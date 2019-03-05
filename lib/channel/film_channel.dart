class FilmChannel{
final _value;
final _name;
const FilmChannel._internal(this._value,this._name);


get value => _value;
get name => _name;


static const ZGGQW = const FilmChannel._internal('http://gaoqing.la/','中国高清网');

static const YINFANS = const FilmChannel._internal('http://www.yinfans.com/','音范丝');
}