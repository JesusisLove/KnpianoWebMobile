package com.liu.springboot06datajpa.db_table.primarykeys;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Column;
import java.io.Serializable;
import java.sql.Date;
import java.util.Objects;
/* 機能番号：KN_LSN_001 【学生授業情報管理】テーブルを生成する */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TInfo_student_documentPK implements Serializable {

    private static final long serialVersionUID = -2397232644712659215L;

    @Column  private String stuId;
    @Column  private String subjectId;
    @Column  private String subjectSubId;
    @Column  private Date adjustedDate;

@Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        TInfo_student_documentPK modelKey = (TInfo_student_documentPK ) o;
        return  Objects.equals(stuId, modelKey.stuId)  
                    &&  Objects.equals(subjectId, modelKey.subjectId) 
                    &&  Objects.equals(subjectId, modelKey.subjectSubId) 
                    &&  Objects.equals(adjustedDate, modelKey.adjustedDate);
    }
    @Override
    public int hashCode() {
        return Objects.hash(stuId, subjectId, subjectSubId, adjustedDate);
    }
}





