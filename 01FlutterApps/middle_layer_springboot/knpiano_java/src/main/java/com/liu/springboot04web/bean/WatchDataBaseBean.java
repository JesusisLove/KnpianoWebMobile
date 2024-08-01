package com.liu.springboot04web.bean;

import java.util.Date;

public class WatchDataBaseBean {
    private String procedureName;
    private String procedureAliasName;
    private String stepName;
    private String result;
    private Date executionTime;

    public String getProcedureName() {
        return procedureName;
    }
    public void setProcedureName(String procedureName) {
        this.procedureName = procedureName;
    }
    public String getProcedureAliasName() {
        return procedureAliasName;
    }
    public void setProcedureAliasName(String procedureAliasName) {
        this.procedureAliasName = procedureAliasName;
    }
    public String getStepName() {
        return stepName;
    }
    public void setStepName(String stepName) {
        this.stepName = stepName;
    }
    public String getResult() {
        return result;
    }
    public void setResult(String result) {
        this.result = result;
    }
    public Date getExecutionTime() {
        return executionTime;
    }
    public void setExecutionTime(Date executionTime) {
        this.executionTime = executionTime;
    }

    
}
