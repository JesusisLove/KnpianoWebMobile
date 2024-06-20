package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.liu.springboot04web.bean.Kn03D002StuDocBean;
import com.liu.springboot04web.bean.Kn05S003SubjectEdabnBean;
import com.liu.springboot04web.dao.Kn03D002StuDocDao;
import com.liu.springboot04web.dao.Kn05S003SubjectEdabnDao;
import com.liu.springboot04web.othercommon.CommonProcess;
import com.liu.springboot04web.service.ComboListInfoService;
import com.liu.springboot04web.bean.Kn01B001StuBean;
import com.liu.springboot04web.dao.Kn01B001StuDao;
import com.liu.springboot04web.bean.Kn01B002SubBean;
import com.liu.springboot04web.dao.Kn01B002SubDao;

import org.springframework.format.annotation.DateTimeFormat;
import java.util.Date;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Service
public class Kn03D002StuDocController {
    private ComboListInfoService combListInfo;

    @Autowired
    private Kn03D002StuDocDao knStudoc001Dao;
    @Autowired
    private Kn01B001StuDao knStu001Dao;
    @Autowired
    private Kn01B002SubDao knSub001Dao;
    @Autowired
    Kn05S003SubjectEdabnDao kn05S003SubjectEdabnDao;

    // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
    public Kn03D002StuDocController(ComboListInfoService combListInfo) {
        this.combListInfo = combListInfo;
    }

    // 【KNPiano后台维护 学生档案管理】ボタンをクリック
    @GetMapping("/kn_studoc_001_all")
    public String list(Model model) {
        // 已经建完档案的学生一览取得
        Collection<Kn03D002StuDocBean> collection = knStudoc001Dao.getInfoList();
        model.addAttribute("stuDocList", collection);

        // 还未建档的学生姓名一览取得
        Collection<Kn03D002StuDocBean> unDocStuList = knStudoc001Dao.getUnDocedList();
        model.addAttribute("unDocStuList", unDocStuList);

        return "kn_studoc_001/knstudoc001_list";
    }

    // 【明细明细検索一覧】検索ボタンを押下
    @GetMapping("/kn_studoc_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("stuDocMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如: stuId改成stu_id
           目的是，这个Map要传递到KnStudoc001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<Kn03D002StuDocBean> searchResults = knStudoc001Dao.searchStuDoc(conditions);
        model.addAttribute("stuDocList", searchResults);
        return "kn_studoc_001/knstudoc001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 【明细明细検索一覧】新規登録ボタンを押下
    @GetMapping("/kn_studoc_001")
    public String toStuDocAdd(Model model) {
        // 告诉前端画面，这是新规登录模式
        model.addAttribute("isAddNewMode", true);

        // 从学生基本信息表里，把学生名取出来，初期化新规/变更画面的学生下拉列表框
        model.addAttribute("stuMap", getStuCodeValueMap());
        // 从科目基本信息表里，把科目名取出来，初期化新规/变更画面的科目下拉列表框
        model.addAttribute("subjects", getSubCodeValueMap());
        // 从科目基本信息表里，把科目名取出来，初期化新规/变更画面的科目枝番下拉列表框
        model.addAttribute("subjectSubs", getEdaBanCodeValueMap());
        final List<String> durations = combListInfo.getMinutesPerLsn();
        model.addAttribute("duration",durations );
        model.addAttribute("selectedStuDoc", null);

        return "kn_studoc_001/knstudoc001_add_update";
    }

    // 【明细明细検索一覧】尚未建档学生ボタンを押下
    @GetMapping("/kn_studoc_001/{stuId}/{stuName}")
    public String toStuDocEdit(@PathVariable("stuId") String stuId, 
                               @PathVariable("stuName") String stuName, 
                                Model model) {
        // 告诉前端画面，这是新规登录模式
        model.addAttribute("isAddNewMode", true);

        // 从学生基本信息表里，把学生名取出来，初期化新规/变更画面的学生下拉列表框
        model.addAttribute("stuMap", getStuCodeValueMap());
        // 从科目基本信息表里，把科目名取出来，初期化新规/变更画面的科目下拉列表框
        model.addAttribute("subjects", getSubCodeValueMap());
        // 从科目基本信息表里，把科目名取出来，初期化新规/变更画面的科目枝番下拉列表框
        model.addAttribute("subjectSubs", getEdaBanCodeValueMap());
        final List<String> durations = combListInfo.getMinutesPerLsn();
        model.addAttribute("duration",durations );

        Kn03D002StuDocBean knStudoc001Bean = new Kn03D002StuDocBean();
        knStudoc001Bean.setStuId(stuId);
        knStudoc001Bean.setStuName(stuName);
        model.addAttribute("selectedStuDoc", knStudoc001Bean);
        return "kn_studoc_001/knstudoc001_add_update";
    }

    // 【新規登録】画面にて、【保存】ボタンを押下
    @PostMapping("/kn_studoc_001")
    public String executeStuDocAdd(Model model, Kn03D002StuDocBean knStudoc001Bean) {
        // 因为是复合主键，只能通过从表里抽出记录来确定是新规操作还是更新操作
        boolean addNewMode = false;

        String stuId = knStudoc001Bean.getStuId();
        String subjectSubId = knStudoc001Bean.getSubjectSubId();
        String subjectId = knStudoc001Bean.getSubjectId();
        Date  adjustedDate = knStudoc001Bean.getAdjustedDate();
        // 确认表里有没有记录，没有就insert，有记录就update
        addNewMode = (knStudoc001Dao.getInfoByKey(stuId, subjectId, subjectSubId, adjustedDate) == null);

        // 画面数据有效性校验
        if (validateHasError(model, knStudoc001Bean, addNewMode)) {
            return "kn_studoc_001/knstudoc001_add_update";
        }
        knStudoc001Dao.save(knStudoc001Bean, addNewMode);
        return "redirect:/kn_studoc_001_all";
    }

    // 【明细明细検索一覧】編集ボタンを押下
    @GetMapping("/kn_studoc_001/{stuId}/{subjectId}/{subjectSubId}/{adjustedDate}")
    public String toStuDocEdit(@PathVariable("stuId") String stuId, 
                               @PathVariable("subjectId") String subjectId, 
                               @PathVariable("subjectSubId") String subjectSubId, 
                               @PathVariable ("adjustedDate") 
                               @DateTimeFormat(pattern = "yyyy-MM-dd") // 从html页面传过来的字符串日期转换成可以接受的Date类型日期
                                Date adjustedDate, 
                                Model model) {
        // 告诉前端画面，这是变更编辑模式
        model.addAttribute("isAddNewMode", false);

        Kn03D002StuDocBean knStudoc001Bean = knStudoc001Dao.getInfoByKey(stuId, subjectId, subjectSubId, adjustedDate);
        model.addAttribute("selectedStuDoc", knStudoc001Bean);

        final List<String> durations = combListInfo.getMinutesPerLsn();
        model.addAttribute("duration",durations );
        
        return "kn_studoc_001/knstudoc001_add_update";
    }

    // 【変更編集】画面にて、【保存】ボタンを押下
    @PutMapping("/kn_studoc_001")
    public String executeStuDocEdit(Model model, Kn03D002StuDocBean knStudoc001Bean) {
        // 因为是复合主键，只能通过从表里抽出记录来确定是新规操作还是更新操作
        boolean addNewMode = false;

        String stuId = knStudoc001Bean.getStuId();
        String subjectSubId = knStudoc001Bean.getSubjectSubId();
        String subjectId = knStudoc001Bean.getSubjectId();
        Date  adjustedDate = knStudoc001Bean.getAdjustedDate();
        // 确认表里有没有记录，没有就insert，有记录就update
        addNewMode = (knStudoc001Dao.getInfoByKey(stuId, subjectId, subjectSubId, adjustedDate) == null);

        // 画面数据有效性校验
        if (validateHasError(model, knStudoc001Bean, addNewMode)) {
            return "kn_studoc_001/knstudoc001_add_update";
        }
        knStudoc001Dao.save(knStudoc001Bean, addNewMode);
        return "redirect:/kn_studoc_001_all";
    }

    // 【明细明细検索一覧】削除ボタンを押下
    @DeleteMapping("/kn_studoc_001/{stuId}/{subjectId}/{subjectSubId}/{adjustedDate}")
    public String executeStuDocDelete (@PathVariable("stuId") String stuId, 
                                            @PathVariable("subjectId") String subjectId, 
                                            @PathVariable("subjectSubId") String subjectSubId, 
                                            @PathVariable("adjustedDate") 
                                            @DateTimeFormat(pattern = "yyyy-MM-dd") // 从html页面传过来的字符串日期转换成可以接受的Date类型日期
                                            Date adjustedDate, 
                                            Model model) {

        knStudoc001Dao.deleteByKeys(stuId, subjectId, subjectSubId, adjustedDate);
        return "redirect:/kn_studoc_001_all";
    }

    // 学生下拉列表框初期化
    private Map<String, String> getStuCodeValueMap() {
        Collection<Kn01B001StuBean> collection = knStu001Dao.getInfoList();

        Map<String, String> map = new HashMap<>();
        for (Kn01B001StuBean bean : collection) {
            map.put(bean.getStuId(), bean.getStuName());
        }

        return map != null ? CommonProcess.sortMapByValues(map) : map;
    }

    // 科目下拉列表框初期化
    private List<Kn01B002SubBean> getSubCodeValueMap() {
        List<Kn01B002SubBean> collection = knSub001Dao.getInfoList();
        return collection;
    }

    // 科目枝番下拉列表框初期化
    private List<Kn05S003SubjectEdabnBean> getEdaBanCodeValueMap() {
        List<Kn05S003SubjectEdabnBean> collection = kn05S003SubjectEdabnDao.getInfoList();
        return collection;
    }

    private boolean validateHasError(Model model, Kn03D002StuDocBean knStudoc001Bean, boolean addNewMode) {
        boolean hasError = false;
        List<String> msgList = new ArrayList<String>();
        hasError = inputDataHasError(knStudoc001Bean, msgList);
        if (hasError == true) {
            // 新规画面下拉列表框项目内容初始化
            model.addAttribute("stuMap", getStuCodeValueMap());
            model.addAttribute("subjects", getSubCodeValueMap());
            model.addAttribute("subjectSubs", getEdaBanCodeValueMap());
            final List<String> durations = combListInfo.getMinutesPerLsn();
            model.addAttribute("duration",durations );

            // 告诉前端画面当前的模式是新规登录还是变更编辑模式
            model.addAttribute("isAddNewMode", addNewMode);

            // 将错误消息显示在画面上
            model.addAttribute("errorMessageList", msgList);
            model.addAttribute("selectedStuDoc", knStudoc001Bean);
        }
        return hasError;
    }

    private boolean inputDataHasError(Kn03D002StuDocBean knStudoc001Bean, List<String> msgList) {
        if (knStudoc001Bean.getStuId()==null || knStudoc001Bean.getStuId().isEmpty() ) {
            msgList.add("请选择学生姓名");
        }

        if (knStudoc001Bean.getSubjectId() == null || knStudoc001Bean.getSubjectId().isEmpty()) {
            msgList.add("请选择科目名称");
        }

        if (knStudoc001Bean.getSubjectSubId() == null || knStudoc001Bean.getSubjectSubId().isEmpty()) {
            msgList.add("请选择科目级别名称");
        }

        if (knStudoc001Bean.getAdjustedDate() == null) {
            msgList.add("请选择价格调整日期");
        }

        if (knStudoc001Bean.getMinutesPerLsn() == null || knStudoc001Bean.getMinutesPerLsn() == 0) {
            msgList.add("请选择上课时长");
        }

        return (msgList.size() != 0);
    }
}