package com.liu.springboot04web.dao;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.Kn01L003ExtraPicesesBean;
import com.liu.springboot04web.mapper.Kn01L003PiesesHasBeenScheMapper;

@Repository
public class Kn01L003PiesesHasBeenScheDao {

    @Autowired
    private Kn01L003PiesesHasBeenScheMapper kn01L003PiesesHasBeenScheMapper;
    
    // 画面初期化，检索
    public List<Kn01L003ExtraPicesesBean> getPicesesHasBeenScheLsnList(String year, String stuId) {
        return kn01L003PiesesHasBeenScheMapper.getPicesesHasBeenScheLsnList(year, stuId);
    }

    // 年度，学生姓名的联动变化
    public List<Kn01L003ExtraPicesesBean> getExtraPicesesIntoOneLsnList(String year, String stuId) {
        return kn01L003PiesesHasBeenScheMapper.getExtraPicesesIntoOneLsnList(year,stuId);
    }

    // 撤销拼凑的加课换正课
    public List<String> getOldLessonIds(String lessonId) {
        return kn01L003PiesesHasBeenScheMapper.getOldLessonIds(lessonId);
    }

    public int undoLogicalDelLesson(String lessonId) {
        return kn01L003PiesesHasBeenScheMapper.undoLogicalDelLesson(lessonId);
    }

    public int undoLogicalDelLsfFee(String lessonId) {
        return kn01L003PiesesHasBeenScheMapper.undoLogicalDelLesson(lessonId);
    }
    // 因为有外键约束，所以要先删除课费表里lessonId记录
    public int deletePiesHsbnScheFee(String lessonId) {
        return kn01L003PiesesHasBeenScheMapper.deletePiesHsbnScheFee(lessonId);
    }

    public int deletePiesHsbnSche(String lessonId) {
        return kn01L003PiesesHasBeenScheMapper.deletePiesHsbnSche(lessonId);
    }

    public int deletePiceseExtraIntoOne(String lessonId) {
        return kn01L003PiesesHasBeenScheMapper.deletePiceseExtraIntoOne(lessonId);
    }

}
