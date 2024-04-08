package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.util.Objects;

/* 機能番号：KN_STU_001 【学生基本情報マスタ】テーブルPKクラス  */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TMst_studentPK implements Serializable  {

    private static final long serialVersionUID = -2397232644712659215L;
    @Column
    private String stuId;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TMst_studentPK modelKey = (TMst_studentPK) o;
        return  Objects.equals(stuId, modelKey.stuId);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(stuId);
    }

}
