package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.util.Objects;
/* 機能番号：KN_SUB_001 【学科基本情報マスタ】テーブルPKクラス */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TMst_subjectPK implements Serializable  {

    private static final long serialVersionUID = -2397232644712659215L;
    @Column  private String subjectId;
    @Column  private String subjectSubId;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TMst_subjectPK modelKey = (TMst_subjectPK ) o;
        return  Objects.equals(subjectId, modelKey.subjectId)  &&   Objects.equals(subjectSubId, modelKey.subjectSubId);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(subjectId ,subjectSubId);
    }

}
