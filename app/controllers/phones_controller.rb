class PhonesController < ApplicationController
  before_action :set_phone, only: [:show, :edit, :update, :destroy]
  
    def extract_feature(phone)
        if phone.price<1000
            return 0
        elsif phone.price>=7000
            return 7
        else
            return phone.price.to_s[0].to_i
        end
    end
    
    def recommender_system(candidates)
      historys=get_historys
  		if historys.nil? || historys.empty?
			  return candidates
		  end
		  if candidates.nil? || candidates.empty?
			  return candidates
			end
        similarities={}
        historys_prices=[]
        for history in historys
            historys_prices.push(extract_feature(history))
        end
        for candidate in candidates
            similarity=999999
            price=extract_feature(candidate)
            for index in 0...historys_prices.length
                temp=(historys_prices[index]-price)**2
                if historys[index].brand!=candidate.brand
                    temp+=1
                end
                temp=temp**(1.0/2)
                if temp<similarity
                    similarity=temp
                    similarities[candidate]=similarity
                end
            end
        end
        similarities=similarities.sort_by{|key,value| value}
        results=[]
        similarities.each do |phone|
            results.push(phone[0])
        end
        return results
    end
    
  
  def get_historys
    orders=Order.where(user_id:session[:userid])
    historys=[]
    orders.each do |order|
      order.items.each do |item|
        historys.push(item.phone)
      end
    end
    return historys
  end

  # GET /phones
  # GET /phones.json
  def index
    @phone=Phone.new
    begin
      @brand=params[:phone][:brand]
    rescue
      @brand=''
    end
    begin
      @price=params[:phone][:price]
    rescue
      @price=''
    end
    if @brand.empty? and @price.empty?
      if session[:userid]
        @phones=Phone.where.not(user_id:session[:userid]).where.not(rubbish:1).where.not(number:0)
        @phones=recommender_system(@phones)
      else
        @phones=Phone.where.not(rubbish:1).where.not(number:0)
      end
    elsif @brand.empty?
      prices=@price.split('-')
      s=0
      b=99999999
      if prices.length==2
        s=prices[0].to_i
        b=prices[1].to_i
      else
        s=prices[0].to_i
      end
      if session[:userid]
        @phones=Phone.where(:price=>s..b).where.not(user_id:session[:userid]).where.not(rubbish:1).where.not(number:0)
        @phones=recommender_system(@phones)
      else
        @phones=Phone.where(:price=>s..b).where.not(rubbish:1).where.not(number:0)
      end
    elsif @price.empty?
      if session[:userid]
        @phones=Phone.where(:brand=>@brand).where.not(user_id:session[:userid]).where.not(rubbish:1).where.not(number:0)
        @phones=recommender_system(@phones)
      else
        @phones=Phone.where(:brand=>@brand).where.not(rubbish:1).where.not(number:0)
      end
    else
      prices=@price.split('-')
      s=0
      b=99999999
      if prices.length==2
        s=prices[0].to_i
        b=prices[1].to_i
      else
        s=prices[0].to_i
      end
      if session[:userid]
        @phones=Phone.where(:brand=>@brand,:price=>s..b).where.not(user_id:session[:userid]).where.not(rubbish:1).where.not(number:0)
        @phones=recommender_system(@phones)
      else
        @phones=Phone.where(:brand=>@brand,:price=>s..b).where.not(rubbish:1).where.not(number:0)
      end
    end
  end

  # GET /phones/1
  # GET /phones/1.json
  def show
    #if not session[:user]
    #  redirect_to {controller:'users',action:"login"}
    #else
    #end
  end

  # GET /phones/new
  def new
    if session[:user]
      @phone = Phone.new
    else
      redirect_to({controller:'users',action:'login'})
    end
  end

  # GET /phones/1/edit
  def edit
  end
  
  def my
    
    @phones=Phone.where(user_id:session[:userid],rubbish:0)
  end

  # POST /phones
  # POST /phones.json
  def create
    #@phone = Phone.new(phone_params)
    @phone=User.find(session[:userid]).phones.build(phone_params)

    respond_to do |format|
      if @phone.save
        format.html { redirect_to @phone, notice: '手机成功发布' }
        format.json { render :show, status: :created, location: @phone }
      else
        format.html { render :new }
        format.json { render json: @phone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phones/1
  # PATCH/PUT /phones/1.json
  def update
    respond_to do |format|
      if @phone.update(phone_params)
        format.html { redirect_to @phone, notice: '修改手机信息成功' }
        format.json { render :show, status: :ok, location: @phone }
      else
        format.html { render :edit }
        format.json { render json: @phone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phones/1
  # DELETE /phones/1.json
  def destroy
    if @phone.number==1
      @phone.destroy
    else
      @phone.rubbish=1
      @phone.save
    end
    respond_to do |format|
      format.html { redirect_to phones_info_url, notice: '成功移除' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phone
      begin
          @phone = Phone.find(params[:id])
      rescue 

      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def phone_params
      params.require(:phone).permit(:name, :brand, :intro, :price, :user_id, :number,:avatar)
    end
end
