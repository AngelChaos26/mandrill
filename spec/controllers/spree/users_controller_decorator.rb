Spree::UsersController.class_eval do
    def shows
        if @user.supplier?
            @orders = @user.supplier_orders.complete.order('completed_at desc')
        else
            @orders = @user.orders.complete.order('completed_at desc')
        end
    end
end