package com.liu.springboot04web.exception;
/*
*  2020/08/04 学习错误信息处理机制 自定义异常处理
* */

public class UserNotExistException extends RuntimeException{

    public UserNotExistException() {
        super("对不起，用户不存在！");
    }
}
