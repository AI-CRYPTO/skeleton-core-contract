pragma solidity ^0.4.23;

contract Storeable {

    struct Storage {
        string url;
        //string host;
        //string port;
        //string path;
    }

    struct FileMeta {
        string name;
        //string extendsion;
    }

    Storage public stored;
    FileMeta public file;
}