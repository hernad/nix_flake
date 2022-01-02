{ lib, pkgs, ... }:

{
  users.users.ana = {
    isNormalUser = true;
    extraGroups = [ "wheel" "disk" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDY0XcmEJNdUOVg6xONb8Nr1jSjUnt7M6jSYPPSKPMYD08gW3tDCgXS2p8DJXXxb7mVoyciY56/UJT2GsBvHgC+dSaE6J4rX0AIdwMOwxOrRyENmT3olu2POu5clhvsewlSHIJaJo809TdhtPMywvKTk3WDp+pdoTfBzz+jbvJ61X8PBTKltxI838yE4Jd+rMHeIemXnDjuNiNeCl8vhvzfAolgharhGqafWqD/YiPWqiGZDOiybtxjior2tCBmmB4daJgxF5logEdh7rWYjKOzPrTwoxvFQ/s1eSq3BTcyJNh+DR+hgls+Z5EqvcMKOIb0qkOoxtqr3ASMUc/9SCT9 ana@nomad"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/uGH1pFZx4221lTvR6tdcdFVsNC1YElPpPm9OYP5cW+h3+K/a/QStcatNAFJzr80cIg61bLVdULy/FTgT58R/gb922QV2Lnz6ZCnzUwT6bDpvmpcMXzUGYGtdUDXLR/Km7fyLSzuxmeGRkRLZxNcntZcrmjVTq1UBl57xgWpWB3Aa+L5/c5X8qaES8+B7x8/8/abtbL7QQe4JxJUZXHjomSiEjFyn2kyMjdZYuaUi6OCZD/ttGQr/zL19ur+ZlgyqCkDM7V6aFKzWxJL4NfJqoepFISDTWrppVvczttzRaifqjK8jcOZ266G2ZnYJJ2GIJCmnALiw+6hmai9hgjo42axMzaEFuwWYKKLKRr4jBLCj5uaF8ZjHqNshiE5LaJ5BZOFMkbkTd+Xf4Q9VVvLNHLu/2rKl7ndoyHMdN4gsZYFl/Papk2zMWFcbZULpAp6XYn/tet1fNfTEa4oO7qs4dOXhVn5j23b68u6tFqLY8eM5a5dOvbmprFxvnb6C/r8= ana@architect"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCuRUWPqN0WvhcOnyFB+5gdJiEbLKo2XY021TMh+z/NtGY3VyLwgtRhMax3eccnrE/GQBDyDbgvdGspfkvKGZL7xorTUPZQZa94RgCJe04TU1LZJ7XqAVXpCQxFFdxG6XpGzcgyy85MyD6XvF8d5vHQOP8Jpx4zPikqFCKrGAazgiQrnISWKFUFxk1mS5YNiZlm9N0uc5isILj0TlYFPr91sKFxVR6QP6ECr9BlXQYRRuUZF7C8vWZgSi3Ygi1kEw9x6hn8As8jZPDByxggq2Lt7E26Lu5c1Yp2wwmY8Er5g8tuV20gHTrs+R42uwRMKSTVC7cyKEcLFz/43WSDqslokd6Y50qmeHJdabyT1uG93/X7nONVQIbTycmLhhwgOZ/JfM68va9Sun3+wKZc65qna3h2gwivMa4pVotg1udNCyAMD1fdyIWKfROsM7niDYGYVB029Of/K4VBCcFkePZinien0szFNowrErowumuMWCzBkZjvPnC6YU4yXVxCAE0= ana@autonoma"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdGj8zlIxR19zrbEsXsu4Gf5a2DYRLVSKuWuKeOgxyBvYbrHBm7jie6GH7SYsgdqI1ap3aRQ9d2GrszeS5FkJ08zp8sXI/Yxz+/rcyTFu/NV2XwJdK1xWedVF2+x2fo7RqP5kWB+V2ARX7a+6FMV38P5DCeUr8IIx2JsvRYJzJpk9u54tz22bO7qTBBaxFzFF2ZQ6PeUtqYqOmYrF/FrvDOUJqxJCJnxtKfyK96ccwUUtKfE/Pwit4GQvFsSop+gw4Cgpo2SwvXdl8YaZpb9A+MF/qw0mKtn10vqr5JdkCvQcygT1e6r3ZCnDPxXr3uGBlW1ehpC2q3nxoCjRsm4c5aRnBIHMygviZb2ZYBTZo6fBfaGHBsQR7ZzM2cY9oLVzB4NsWitcP5egRNMqplOjARYb/Tq2AF/KGIPXPJ5g6IbqsLXLatUTikP9vvY6heNSm7bpk9aeNtMbq+iKc99EoMndmgLu1wL93Syae/4SeWEAnCO5vlBtqWG9It9hQ8I0= ana@gizmo"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD7L/nONXb8lpWUBZlYfOpl3cnZn7g7mlkpYfToxI8PTvMJJRRvsP1Gi6cNKeIarOzI4Gbu6mwAWGS9z6IKXs3Fp0bm0Wfinm0tml02zi3zQZqlonlwkMpn9wIKEyqH5d9Q2pMSjSPjXsbLneAOQZMz9tS9tPPySNOq3YkH12t51Nd0fxRR6d7GsqDvB1ya/eSLj6H0W9Qo8oLrsPUy3V8QF2wVCOhIzjYxPMU2q14yeHns+UyfbAJorLike+du06/xYrmNIUkLdGxQvjLtz3BrqWHq/Q3SUVLy1dzhxUXbxyWoQ4MqUYJxSBgzMS0PHYR/+QH7ijUL/XHnW6P6FJIqB3c3l43JUVFTYiGkRecGzSjoQkuzghx2nz5lDG4/0b/4W0upa7gUCBsr1rUgsAtzvQ5IPeEWSF6OiKxM64O5YwMI2fuyHrCWak6FL//LN4zdbbZ86F7wyBPFAs+RU9TkG27ZVbmqu5EWluoXhg2bNywI3VNq9JTyDWHuPnMvr+E= ana@quartz"
    ];
  };
}
