package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.util.Objects;
/* 機能番号：KN_LSN_PAY_001 【課費支払管理】テーブルを生成する */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TInfo_lesson_payPK implements Serializable {

    private static final long serialVersionUID = -2397232644712659215L;

    @Column  private String lsnPayId;
    @Column  private String lsnFeeId;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TInfo_lesson_payPK modelKey = (TInfo_lesson_payPK ) o;
        return  Objects.equals(lsnPayId, modelKey.lsnPayId)  &&  Objects.equals(lsnFeeId, modelKey.lsnFeeId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(lsnPayId ,lsnFeeId);
    }
}