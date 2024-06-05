package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.util.Objects;

/* 機能番号：KN_FIXf_LSN_001 【学生銀行番号管理】テーブルを生成する */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TInfo_student_bankPK implements Serializable {
    private static final long serialVersionUID = -2397232644712659215L;
    @Column  private String stuId;
    @Column  private String bankId;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TInfo_student_bankPK modelKey = (TInfo_student_bankPK ) o;
        return  Objects.equals(stuId, modelKey.stuId)  &&  Objects.equals(bankId, modelKey.bankId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(stuId ,bankId);
    }
}

