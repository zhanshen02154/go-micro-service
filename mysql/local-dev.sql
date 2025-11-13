# 在MySQL所在的服务器上用root登录

# 创建本地开发者账号
CREATE USER `<username>`@`<local IP>` IDENTIFIED WITH mysql_native_password BY <password>;
GRANT Alter, Create, Create Routine, Create Temporary Tables, Create View, Delete, Drop, Event, Execute, Index, Insert, Lock Tables, References, Select, Show View, Update 
	ON `products`.* TO `<username>`@`<local IP>`;
GRANT Alter, Create, Create Routine, Create Temporary Tables, Create View, Delete, Drop, Event, Execute, Index, Insert, Lock Tables, References, Select, Show View, Update 
	ON `orders`.* TO `<username>`@`<local IP>`;
FLUSH PRIVILEGES;

# 更新IP地址及权限
UPDATE mysql.user SET host = '<new IP>' WHERE user = '<username>';
FLUSH PRIVILEGES;
GRANT Alter, Create, Create Routine, Create Temporary Tables, Create View, Delete, Drop, Event, Execute, Index, Insert, Lock Tables, References, Select, Show View, Update 
	ON `products`.* TO `<username>`@`<local IP>`;
GRANT Alter, Create, Create Routine, Create Temporary Tables, Create View, Delete, Drop, Event, Execute, Index, Insert, Lock Tables, References, Select, Show View, Update 
	ON `orders`.* TO `<username>`@`<local IP>`;
FLUSH PRIVILEGES;