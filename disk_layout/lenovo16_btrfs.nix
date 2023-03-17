{
  diskPart = {  
     diskName = "nvme0n1";  
     efi = "${diskName}p1";
     root = "${diskName}p2";
     #swap = "${diskName}p3";
  };   
}