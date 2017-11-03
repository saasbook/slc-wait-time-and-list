class StudentsController < ApplicationController
  def index
    render "students/new"
  end

  def new
    #render new template
    flash[:notice] = nil
  end

  def create
    sid = params[:student_sid]
    if Student.where(:sid => sid).empty?
      @student = Student.create(:first_name => params[:student_first_name],
                               :last_name => params[:student_last_name],
                               :sid => sid,
                               :email => params[:student_email])
    else
      @student = Student.find(sid)
    end
    unless @student.student_queues.empty?
      flash[:notice] = 'you are already in line'
      render "students/new"
      return
    end

    @student.student_queues.build(:course => params[:course], :meet_type => params[:meet_type], :status => "waiting")
    @student.save
    case params[:meet_type]
      when 'scheduled', 'weekly'
        flash[:notice] = 'you are now in line!'
      when 'drop-in'
        redirect_to wait_time_student_queue_path(@student.sid)
        return
      else
        flash[:notice] = 'please select a service type'
    end
    render "students/new"
  end
end